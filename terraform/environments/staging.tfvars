aws_region    = "eu-north-1"
instance_type = "t3.small"
key_name      = "irfan-strapi-key-staging"
ecr_registry  = "301782007642.dkr.ecr.eu-north-1.amazonaws.com"
docker_image  = "301782007642.dkr.ecr.eu-north-1.amazonaws.com/irfan-strapi-image:latest"

# Database credentials
db_name     = "strapidb_staging"
db_username = "strapiuser_staging"
db_password = "ChangeMe@StagingPassword123"
