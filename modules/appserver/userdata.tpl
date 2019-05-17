#!/bin/bash
set -e -x
# This script is meant to be run in the User Data of Jenkins EC2 Instance while it's booting.


#Install Jenkins
sudo yum update –y
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user