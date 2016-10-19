#!/bin/bash
set -e 

# Ensure we have unzip
sudo apt-get install -y unzip

# Alter version for the current version and grab binary, extracting into /usr/local/bin - Is a single binary
version=0.10.2
wget -O /tmp/packer.zip https://releases.hashicorp.com/packer/${version}/packer_${version}_linux_amd64.zip
sudo unzip -o /tmp/packer.zip -d /usr/local/bin

# Check version
packer version
