#!/bib/bash
set -e 

# Assuming we are using a distro with python3`
python3 --version

# Install pip
curl -O https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py

# Install AWS CLI
sudo pip install awscli

# Echo version
aws --version
