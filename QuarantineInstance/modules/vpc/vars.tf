variable "aws_region" {}

variable "quarantine_instance_vpc_cidr" {
  default = "192.168.23.0/24"
}

variable "instance_tenancy" {
  default = "default"
}

variable "vpc_name" {
  default = "quarantine_instances_vpc"
}

variable "public_subnet_cidr_block" {
  default = "192.168.23.0/26"
}

variable "public_subnet_az" {
  default = "us-east-1a"
}

variable "private_subnet_cidr_block" {
  default = "192.168.23.64/26"
}

variable "private_subnet_az" {
  default = "us-east-1a"
}

variable "bastion_host_sg_ingress_cidr_blocks" {
  type = "list"
  default = ["1.2.3.4/32"]
}
