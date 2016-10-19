#!/bin/bash
set -e 

# Ensure we  have unzip
sudo apt-get install -y unzip

# Alter version for the current version and grab binary, extracting into /usr/local/bin - Is a single binary since 0.7.0
version=0.7.6
wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip
sudo unzip -o /tmp/terraform.zip -d /usr/local/bin

# Check version
terraform version
