# Create Jenkins Instance using Terraform
# @author Huzefa Hamdard
#Tell terraform that we will use AWS provider
provider "aws" {
  access_key  = "${var.aws_access_key}"
  secret_key  = "${var.aws_secret_key}"
  region      = "${var.aws_region}"
}

provider "template"{
    version = "~> 0.1"
}

#Commenting for fast processing
# #Put terraform state file to S3
# terraform{
#     backend "s3"{
      
#     }
# }

# # #Set path to store terraform state file. 
# data "terraform_remote_state" "jenkins_state" {
#     backend = "s3"
#     access_key  = "${var.aws_access_key}"
#     secret_key  = "${var.aws_secret_key}"
#     config {
#         #bucket = "${var.s3prefix}-terraform-states-${var.region}"
#         bucket = "${var.s3bucketname}"
#         #key = "${var.env_name}/jenkins.tfstate"
#         key = "jenkins_state/jenkins.tfstate"
#         region = "${var.aws_region}"
#     }
#  }

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_subnet" "selected" {
  id = "subnet-118ef43f"
}

# Appserver private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = "${data.aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name = "Appserver Private Subnet"
  }
}

resource "aws_eip" "private-nat" {
vpc      = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${data.aws_vpc.default.id}"

  tags {
    Name = "VPC IGW"
  }
}

# Public route
resource "aws_route_table" "jenkins-public" {
    vpc_id = "${data.aws_vpc.default.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }

    tags {
        Name = "jenkins-public"
    }
}

# Public route table
resource "aws_route_table_association" "jenkins-public-a" {
    subnet_id = "${data.aws_subnet.selected.id}"
    route_table_id = "${aws_route_table.jenkins-public.id}"
}


resource "aws_nat_gateway" "private-nat-gw" {
allocation_id = "${aws_eip.private-nat.id}"
#subnet_id = "${data.aws_subnet_ids.default.ids}"
subnet_id = "${data.aws_subnet.selected.id}"
depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_route_table" "appserver-private-rt" {
  vpc_id = "${data.aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.private-nat-gw.id}"
  }
  tags {
    Name = "Private Subnet RT"
  }
}

# Assign the route table to the private Subnet
resource "aws_route_table_association" "appserver-private-rt" {
  subnet_id = "${aws_subnet.private-subnet.id}"
  route_table_id = "${aws_route_table.appserver-private-rt.id}"
}


module "jenkins" {
  source                      = "./modules/jenkins"
  vpc_id                      = "${data.aws_vpc.default.id}"
  name                        = "jenkins"
  instance_type               = "${var.instance_type_master}"
  ami_id                      = "${var.ami_id}"
  user_data                   = "${data.template_file.user_data.rendered}"
  setup_data                  = "${data.template_file.setup_data.rendered}"
  key_name                    = "${var.ssh_key_name}"
  http_port                   = "${var.http_port}"
  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  #subnet_ids                  = "${data.aws_subnet_ids.default.ids}"
  subnet_id                   = "${data.aws_subnet.selected.id}"
}

module "appserver" {
  source                      = "./modules/appserver"
  vpc_id                      = "${data.aws_vpc.default.id}"
  name                        = "appserver"
  instance_type               = "${var.instance_type_master}"
  ami_id                      = "${var.ami_id}"
  user_data                   = "${data.template_file.user_data_appserver.rendered}"
  setup_data                  = "${data.template_file.setup_data.rendered}"
  key_name                    = "${var.ssh_key_name}"
  http_port                   = "${var.http_port}"
  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  subnet_id                  = "${aws_subnet.private-subnet.id}"
}

data "template_file" "setup_data" {
  template = "${file("./modules/jenkins/setup.tpl")}"

  vars = {
    jnlp_port = "${var.jnlp_port}"
    plugins = "${join(" ", var.plugins)}"
  }
}
data "template_file" "user_data" {
  template = "${file("./modules/jenkins/userdata.tpl")}"
}

data "template_file" "user_data_appserver" {
  template = "${file("./modules/appserver/userdata.tpl")}"
}



