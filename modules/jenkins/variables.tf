variable "name" {
  description = "Name for the Jenkins instance"
}

variable "environment" {
  description = "The environement tag to add to Jenkins instance",
  default     = ""
}

variable "ami_id" {
  description = "The ID of the AMI to run in this Jenkins instance"
}

variable "instance_type" {
  description = "Instance Type to use for Jenkins"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  default = ""
}

variable "subnet_ids" {
  description = "Subnets for the load balancer listener to use"
  type = "list"
}

variable "user_data" {
  description = "A User Data script to execute while the server is booting."
}

variable "setup_data" {
  description = "A User Data script to execute after server has booted to setup jenkins defaults."
}

variable "key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster."
  #default     = ""
}

variable "ssh_key_path" {
  description = "The path of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Used for provisioning."
  default     = ""
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections on SSH"
  type        = "list"
}

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Jenkins"
  type        = "list"
}

variable "ssh_port" {
  description = "The port used for SSH connections"
  default     = 22
}

variable "http_port" {
  description = "The port to use for HTTP traffic to Jenkins"
  default     = 8080
}

variable "https_port" {
  description = "The port to use for HTTPS traffic to Jenkins"
  default     = 443
}

variable "jnlp_port" {
  description = "The port to use for TCP traffic between Jenkins intances"
  default     = 49187
}

variable "tags" {
  type = "map"
  description = "Tag for the instance"
  default = {
  }
}