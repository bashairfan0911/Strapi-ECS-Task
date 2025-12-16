# Production environment configuration
aws_region    = "eu-north-1"
instance_type = "t3.medium"
key_name      = "irfan-strapi-key-prod"
ecr_registry  = "301782007642.dkr.ecr.eu-north-1.amazonaws.com"
docker_image  = "301782007642.dkr.ecr.eu-north-1.amazonaws.com/irfan-strapi-image:latest"

# Database credentials
db_name     = "strapidb_prod"
db_username = "strapiuser_prod"
db_password = "ChangeMe@SecurePassword123"
