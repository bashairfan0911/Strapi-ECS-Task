# AWS Region
variable "aws_region" {
  type        = string
  description = "AWS region for resources"
}

# EC2 Variables
variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "EC2 Key Pair name"
}

# Docker & ECR Variables
variable "docker_image" {
  type        = string
  description = "Docker image URI from ECR"
}

variable "docker_image_tag" {
  type        = string
  default     = "latest"
  description = "Docker image tag (commit SHA or 'latest')"
}

variable "ecr_registry" {
  type        = string
  description = "ECR registry URL"
}

# Database Variables
variable "db_name" {
  type        = string
  default     = "strapidb"
  description = "Database name"
}

variable "db_username" {
  type        = string
  default     = "strapiuser"
  description = "Database username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password (should be from .tfvars)"
}
