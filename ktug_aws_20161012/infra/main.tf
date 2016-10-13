/*
	Going to keep all in a single file as not much here, would normally break into varibales.tf, ouputs.tf etc.
	This is not json, this is HCL, see https://github.com/hashicorp/hcl
	See https://www.terraform.io/docs/providers/aws/
	Going to order alphabetically
	Going to use vars all over

	Will create the following
		A single VPC
		2 subnets in the first AZ
			- Public will host the NAT gateway and any public EC2 instances
			- Private - will host EC2 instances that do not have public IPs, will go via the NAT Gateway to access the internet
		1 Elastic IP
		1 internet gateway for the VPC
		1 NAT gateway with the EIP in the public subnet
		2 route tables
			- Public that has a 0.0.0.0/0 route via the internet gateway
			- Private that has a 0.0.0.0/0 route via the NAT gateway gateway
		3 security groups
			- App
				- 22 from Bastion SG
				- 5000 from WebFront SG
			- Bastion
				- 22 from my IP
				- 22 to WebFront SG
				- 22 to App SG
			- WebFront
				- 22 from Bastion SG
				- 80 from internet
				- 5000 to App SG

		Did not bother with NACLs - just allowed the subnets to default to the default NACL created when the VPC was created
*/

# See https://www.terraform.io/docs/providers/aws/d/availability_zones.html
data "aws_availability_zones" "available" {}

# Outputs
output "nat_gateway_public_ip" {
  value = "${aws_eip.nat.public_ip}"
}

# Configure the AWS Provider - Will only set the region - do not want to commit access keys to SCM - that would be expensive
provider "aws" {
  region = "${var.aws_region}"
}

# See https://www.terraform.io/docs/providers/aws/r/eip.html
resource "aws_eip" "nat" {}

# See https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

# See https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
resource "aws_nat_gateway" "main" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"
}

# See https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "internet" {
  route_table_id         = "${aws_route_table.internet.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route" "nat" {
  route_table_id         = "${aws_route_table.nat.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.main.id}"
}

# See https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route_table" "internet" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name}-internet"
  }
}

resource "aws_route_table" "nat" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name}-nat"
  }
}

# See https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "app" {
  vpc_id = "${aws_vpc.main.id}"
  name   = "${var.vpc_name}-app"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = ["${aws_security_group.bastion.id}"]
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = "${aws_vpc.main.id}"
  name   = "${var.vpc_name}-bastion"

  egress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["${var.bastion_ssh_access_cidr_block}"]
  }
}

resource "aws_security_group" "webfront" {
  vpc_id = "${aws_vpc.main.id}"
  name   = "${var.vpc_name}-webfront"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = ["${aws_security_group.bastion.id}"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

# See https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
# Cannot inline some of these due to cyclic issues, so need to extract
resource "aws_security_group_rule" "app_ingress_webfront_5000" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.app.id}"
  source_security_group_id = "${aws_security_group.webfront.id}"
}

resource "aws_security_group_rule" "webfront_egress_app_5000" {
  type                     = "egress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.webfront.id}"
  source_security_group_id = "${aws_security_group.app.id}"
}

# See https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "private" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block        = "${var.private_subnet_cidr_block}"
  vpc_id            = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name}-private"
  }
}

resource "aws_subnet" "public" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block        = "${var.public_subnet_cidr_block}"
  vpc_id            = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name}-public"
  }
}

# See https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_block}"

  tags {
    Name = "${var.vpc_name}"
  }
}

# Variables - going with defaults for most but these can be overriden via TF_VAR env vars or parameters
variable "aws_region" {
  default = "eu-west-1"
}

variable "bastion_ssh_access_cidr_block" {}

variable "private_subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "public_subnet_cidr_block" {
  default = "10.0.0.0/24"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  default = "ktug"
}
