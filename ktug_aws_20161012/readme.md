# Setup


## AWS access key
- Generate AWS access keys for an account user with admin privileges, see http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html
- Don't bother downloading file, just paste as instructed below


## Configure local profile for the AWS account
```
# Ensure we have an .aws directory
[ -d ~/.aws ] || echo mkdir ~/.aws

# Set these, use space so not in your history
 profile_name=pmcsecret-pmcgrath-admin
 access_key_id=FILL_ME_IN
 secret_access_key=FILL_ME_IN

 cat >> ~/.aws/credentials <<EOF


[$profile_name]
aws_access_key_id = $access_key_id
aws_secret_access_key = $secret_access_key
EOF
```


## AWS CLI
```
# Verify that you have Python 2.7.6+
# Will check for python3 in case of 16.04+
python --version
python3 --version

# Install pip
curl -O https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py                      # Use python3 on 16.04+, have NOT verified that it works

# Install AWS CLI
sudo pip install awscli

# Echo version
aws --version
```


## Packer
- See https://www.packer.io/downloads.html
```
# Ensure you have unzip
sudo apt-get install -y unzip

# Alter version for the current version and grab binary, extracting into /usr/local/bin - Is a single binary
version=0.10.2
wget -O /tmp/packer.zip https://releases.hashicorp.com/packer/${version}/packer_${version}_linux_amd64.zip
sudo unzip -o /tmp/packer.zip -d /usr/local/bin

# Check version
packer version
```


## Terraform
- See https://www.terraform.io/downloads.html
```
# Ensure you have unzip
sudo apt-get install -y unzip

# Alter version for the current version and grab binary, extracting into /usr/local/bin - Is a single binary since 0.7.0
version=0.7.6
wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip
sudo unzip -o /tmp/terraform.zip -d /usr/local/bin

# Check version
terraform version
```










