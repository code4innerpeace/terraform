resource "aws_vpc" "quarantine_instances_vpc" {
  cidr_block           = var.quarantine_instance_vpc_cidr
   enable_dns_hostnames = true
  instance_tenancy     = var.instance_tenancy
  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.quarantine_instances_vpc.id
  tags = {
    "Name" = "${var.vpc_name}_igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.quarantine_instances_vpc.id
  cidr_block              = var.public_subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.public_subnet_az
  tags = {
    "Name" = "${var.vpc_name}_public"
  }
}

resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.quarantine_instances_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = {
    "Name" = "${var.vpc_name}_public_subnet_rt"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet_rt.id
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.quarantine_instances_vpc.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = var.private_subnet_az
  tags = {
    "Name" = "${var.vpc_name}_private"
  }
}

resource "aws_route_table" "private_subnet_rt" {
  vpc_id = aws_vpc.quarantine_instances_vpc.id
  tags = {
    "Name" = "${var.vpc_name}_private_subnet_rt"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_subnet_rt.id
}

resource "aws_security_group" "bastion_host_sg" {
  name        = "${var.vpc_name}_bastion_host_sg"
  description = "Allow inbound traffic internal networks"
  vpc_id      = aws_vpc.quarantine_instances_vpc.id
}

resource "aws_security_group_rule" "ingress_allow_22_from_internal_networks" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.bastion_host_sg_ingress_cidr_blocks

  security_group_id = aws_security_group.bastion_host_sg.id
}

resource "aws_security_group_rule" "egress_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_host_sg.id
}

resource "aws_security_group" "quarantine_instances_sg" {
  name        = "${var.vpc_name}_quarantine_instances_sg"
  description = "Allow inbound traffic bastion host"
  vpc_id      = aws_vpc.quarantine_instances_vpc.id
}

resource "aws_security_group_rule" "allow_22_from_bastion_host_sg" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_host_sg.id

  security_group_id = aws_security_group.quarantine_instances_sg.id
}
