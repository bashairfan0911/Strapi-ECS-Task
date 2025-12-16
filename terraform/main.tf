# VPC Module
module "vpc" {
  source = "./modules/vpc"
}

# Security Groups Module
module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  subnet_ids             = module.vpc.subnet_ids
  rds_security_group_id  = module.security.rds_sg_id
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = module.vpc.first_subnet_id
  security_group_id = module.security.strapi_sg_id
  docker_image      = var.docker_image
  aws_region        = var.aws_region
  ecr_registry      = var.ecr_registry
  db_host           = module.rds.db_endpoint
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}
