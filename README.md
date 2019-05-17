#terraform"# jenkins_terraform" 

#Steps to execute
terraform init

terraform plan -out "jenkinsplan"
It will ask for AWS access, secret key, region 
  ID of AMI to use for instance

  Enter a value: ami-0de53d8956e8dcf80

var.aws_access_key
  Access Key of AWS

  Enter a value: XXXXX

var.aws_region
  The AWS region to spon instance.

  Enter a value: us-east-1

var.aws_secret_key
  Secet Key for AWS

  Enter a value: XXXXX


terraform apply "jenkinsplan" 
