/*
	Going to keep all in a single file as not much here, would normally break into variables.tf, ouputs.tf etc.
	This is not json, this is HCL, see https://github.com/hashicorp/hcl
	See https://www.terraform.io/docs/providers/aws/
	Going to order alphabetically
	Going to use vars all over

	Will create the following
		A single VPC
		A pair of subnets in the the first N subnets where N is the var.availability_zone_count value
			- Public will host the NAT gateway and any public EC2 instances
			- Private - will host EC2 instances that do not have public IPs, will go via the NAT Gateway to access the internet
		N Elastic IPs where N is the var.availability_zone_count value
		1 internet gateway for the VPC
		N NAT gateway with the EIP in the public subnets where N is the var.availability_zone_count
		N + 1 route tables
			- Public that has a 0.0.0.0/0 route via the internet gateway
			- N Private that has a 0.0.0.0/0 route via the NAT gateways where N is the var.availability_zone_count value
		N + 1 route table associations - subnets to route tables
		3 security groups
			- App
				- 22 from Bastion SG
				- 5000 from WebFront SG
				- 80 to 0.0.0.0/0
				- 443 to 0.0.0.0/0
			- Bastion
				- 22 from my IP
				- 22 to WebFront SG
				- 22 to App SG
				- 80 to 0.0.0.0/0
				- 443 to 0.0.0.0/0
			- WebFront
				- 22 from Bastion SG
				- 80 from internet
				- 443 from internet
				- 5000 to App SG
				- 80 to 0.0.0.0/0
				- 443 to 0.0.0.0/0

		Did not bother with NACLs - just allowed the subnets to default to the default NACL created when the VPC was created
*/

# See https://www.terraform.io/docs/providers/aws/d/availability_zones.html
data "aws_availability_zones" "available" {}

# Outputs
output "nat_gateway_public_ips" {
  value = "${list(aws_eip.nat_gateway.*.public_ip)}"
}

output "private_subnet_ids" {
  value = "${list(aws_subnet.private.*.id)}"
}

output "public_subnet_ids" {
  value = "${list(aws_subnet.public.*.id)}"
}

# Configure the AWS Provider - Will only set the region - do not want to commit access keys to SCM - that would be expensive
provider "aws" {
  region = "${var.aws_region}"
}

# See https://www.terraform.io/docs/providers/aws/r/eip.html
resource "aws_eip" "nat_gateway" {
  count = "${var.availability_zone_count}"
}

# See https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

# See https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
resource "aws_nat_gateway" "main" {
  allocation_id = "${aws_eip.nat_gateway.*.id[count.index]}"
  count         = "${var.availability_zone_count}"
  depends_on    = ["aws_internet_gateway.main"]
  subnet_id     = "${aws_subnet.public.*.id[count.index]}"
}

# See https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "internet" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.vpc_name}-internet"
  }
}

resource "aws_route_table" "nat" {
  count  = "${var.availability_zone_count}"
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.main.*.id[count.index]}"
  }

  tags {
    Name = "${var.vpc_name}-nat-${count.index}"
  }
}

# See https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "private" {
  count          = "${var.availability_zone_count}"
  route_table_id = "${aws_route_table.nat.*.id[count.index]}"
  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
}

resource "aws_route_table_association" "public" {
  count          = "${var.availability_zone_count}"
  route_table_id = "${aws_route_table.internet.id}"
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
}

# See https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "app" {
  description = "Apps"
  name        = "${var.vpc_name}-app"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group" "bastion" {
  description = "Bastions"
  name        = "${var.vpc_name}-bastion"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group" "webfront" {
  description = "Web frontends"
  name        = "${var.vpc_name}-webfront"
  vpc_id      = "${aws_vpc.main.id}"
}

# See https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
# Cannot inline some of these in the security groups due to cyclic issues, also warns about mixing inline and external rules, so need to extract all
resource "aws_security_group_rule" "app_egress_all_80" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.app.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_egress_all_443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.app.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_ingress_bastion_22" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.app.id}"
  source_security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "app_ingress_webfront_5000" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.app.id}"
  source_security_group_id = "${aws_security_group.webfront.id}"
}

resource "aws_security_group_rule" "bastion_egress_vpc_22" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks       = ["${var.vpc_cidr_block}"]
}

resource "aws_security_group_rule" "bastion_egress_all_80" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_egress_all_443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_ingress_secure_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks       = ["${var.bastion_ssh_access_cidr_block}"]
}

resource "aws_security_group_rule" "webfront_egress_all_80" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.webfront.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "webfront_egress_all_443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.webfront.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "webfront_egress_app_5000" {
  type                     = "egress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.webfront.id}"
  source_security_group_id = "${aws_security_group.app.id}"
}

resource "aws_security_group_rule" "webfront_ingress_bastion_22" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.webfront.id}"
  source_security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "webfront_ingress_all_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.webfront.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "webfront_inress_all_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.webfront.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

# See https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "private" {
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.private_subnet_cidr_blocks[count.index]}"
  count             = "${var.availability_zone_count}"
  vpc_id            = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name}-private-${count.index}"
  }
}

resource "aws_subnet" "public" {
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block              = "${var.public_subnet_cidr_blocks[count.index]}"
  count                   = "${var.availability_zone_count}"
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name}-public-${count.index}"
  }
}

# See https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.vpc_name}"
  }
}

# Variables - going with defaults for most but these can be overriden via TF_VAR env vars or parameters
variable "aws_region" {
  default = "eu-west-1"
}

variable "availability_zone_count" {
  default = 2
}

variable "bastion_ssh_access_cidr_block" {
  description = "CIDR block that is allowed access the bastions - Will need to supply - Your IP address with a /32"
}

variable "private_subnet_cidr_blocks" {
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10/0.14.0/24"]
}

variable "public_subnet_cidr_blocks" {
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10/0.4.0/24"]
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  default = "ktug"
}
