provider "aws" {
  region = var.aws_region
}
terraform {
  backend "s3" {
    region  = "us-east-1"
    bucket  = "quarantine-buck"
    key     = "terraform.tfstate"
    encrypt = true
  }
}

module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
}

module "stepfunctions" {
  source              = "./modules/stepfunctions"
  aws_region          = var.aws_region
  project_name        = var.project_name
  subnet_id           = module.vpc.private_subnet_id
  security_group_ids  = module.vpc.quarantine_instances_sg
  ssm_parameter_store = var.ssm_parameter_store
}

module "iotbutton" {
  source       = "./modules/iotbutton"
  aws_region   = var.aws_region
  project_name = var.project_name
  sfn_arn      = module.stepfunctions.state_machine_name_id
  topic_arn    = module.stepfunctions.quarantine_instance_topic_arn
}
