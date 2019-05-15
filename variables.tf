variable "aws_region" {
  description = "The AWS region to spon instance."
}

variable "aws_access_key" {
  description = "Access Key of AWS"
}

variable "aws_secret_key" {
  description = "Secet Key for AWS"
}
variable "ami_id" {
  description = "ID of AMI to use for instance"
  #default     = ""
}

# variable "s3bucketname" {
#   description  = "S3 bucket name where terraform state file is maintained"
# }
variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster."
  #default     = ""
}

variable "instance_type_master" {
  description = "Instance Type to use for instance"
  default     = "t2.micro"
}

variable "http_port" {
  description = "The port to use for HTTP traffic to Jenkins"
  default     = 8080
}

variable "jnlp_port" {
  description = "The Port to use for Jenkins master to slave communication bewtween instances"
  default     = 49187
}
variable "plugins" {
  type        = "list"
  description = "A list of Jenkins plugins to install, use short names."
  default     = ["git", "xunit", "Pipeline", "docker-commons", "docker-workflow"]
}

variable "tags" {
  type = "map"
  description = "Supply tags you want added to all resources"
  default = {
  }
}