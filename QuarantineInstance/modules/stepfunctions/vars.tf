variable "aws_region" {}
variable "project_name" {}
variable "subnet_id" {}
variable "security_group_ids" {}
variable "ssm_parameter_store" {}

variable "ssh_key_name" {
  default = "quarantine_instance_ssh"
}
