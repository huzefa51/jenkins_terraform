#!/bin/bash
set -e -x
# This script is meant to be run in the User Data of Jenkins EC2 Instance while it's booting.


#Install Jenkins
sudo yum update –y
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum install java-1.8.0-openjdk-devel -y
sudo yum install jenkins -y

sudo service jenkins start
sudo chkconfig --add jenkins
