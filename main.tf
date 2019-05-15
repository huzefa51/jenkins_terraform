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
  subnet_ids                  = "${data.aws_subnet_ids.default.ids}"
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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}