# Setup
- Tools

## AWS CLI - could also use awshell, see https://github.com/awslabs/aws-shell
```
# Assuming we are using a distro with python3
python3 --version

# Install pip
curl -O https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py

# Install AWS CLI
sudo pip install awscli

# Echo version
aws --version
```


## AWS autocompletion - add to bashrc - dependent on dotfile management
```
echo -e "\n# AWS auto-completion\ncomplete -C \$(which aws_completer) aws\n" >> ~/.bashrc

# Can re-source so we have autocompletion immediately
source ~/.bashrc
```


## jq installation
```
sudo apt-get install -y jq
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



# CLI demo
- DO NOT DELETE YOUR DEFAULT VPC - Here lies pain


## AWS access key
- Generate AWS access keys for an account user with admin privileges, see http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html
- Don't bother downloading file, just paste as instructed below
- Using a profile - can have many and switch between them (Special case is the default profile)



## Configure named local profile for the AWS account
```
# Ensure we have an .aws directory
[ -d ~/.aws ] || echo mkdir ~/.aws

# Set these, use space so not in your history
 profile_name=ACCOUNT_NAME_USER_NAME
 access_key_id=FILL_ME_IN
 secret_access_key=FILL_ME_IN

 cat >> ~/.aws/credentials <<EOF


[$profile_name]
aws_access_key_id = $access_key_id
aws_secret_access_key = $secret_access_key
EOF

# Configure env to use the profile
export AWS_PROFILE=FILL_ME_IN_IF_NOT_DEFAULT
export AWS_REGION=eu-west-1
export AWS_DEFAULT_REGION=eu-west-1
```


## Use env vars instead of a profile - Close terminal\session all gone
```
export AWS_ACCESS_KEY_ID=FILL_ME_IN
export AWS_SECRET_ACCESS_KEY=FILL_ME_IN
export AWS_REGION=eu-west-1
export AWS_DEFAULT_REGION=eu-west-1
```


## Some simple queries using the CLI
- See https://aws.amazon.com/cli/
```
# Version
aws --version

# Auto completion
aws TAB TAB
aws ec2 TAB TAB

# List all users
aws iam list-users

# List VPCs
aws ec2 describe-vpcs

# Create A VPC, capturing the Id using jq
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.240.0.0/16 | jq -r '.Vpc.VpcId')

# Tag the VPC
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=ted

# List VPCs
aws ec2 describe-vpcs

# Delete the VPC
aws ec2 delete-vpc --vpc-id $VPC_ID

# List VPCs
aws ec2 describe-vpcs
```

- Other tools and SDKs will look for credentials using the same config
	- Profile env var
	- Env var values
	- Explicit values in code



# Terraform
- See https://www.terraform.io/
- Decalaritive infrastructure as code
	- AWS networks
	- IAM users\roles etc
	- DynamoDB\SQS etc
	- EC2\ECS instances
- Providers one of which is AWS, see https://www.terraform.io/docs/providers/aws/index.html
- No logic
	- People build scripts\little tools above usage
- Workflow is
	- Plan
	- Apply
	- Destroy


## Create a VPC
#### Create a definition
- Single file - main.tf
- Can use multiple files
- Can use modules to reduce
- Will show a variable
- Will show an output

```
output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

# See https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.vpc_name}"
  }
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  default = "ktug"
}
```


### Validate
```
terraform validate
```


#### Plan
```
terraform plan
```
- Will show
	- Creation +
	- Destruction -
	- Alteration ~


#### Apply
```
terraform apply
```

- State file
- Outputs
- Commit state file  - Can store remotely in S3 rather than in the local repo


## Alter the VPC name - will pass as a var
```
terraform plan -var "vpc_name=ktug-1"
terraform apply -var "vpc_name=ktug-1"
```


#### Teardown
```
terraform destroy
```
- Statefile
