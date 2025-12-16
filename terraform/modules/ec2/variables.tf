variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "EC2 Key Pair name"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for EC2 instance"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for EC2 instance"
}

variable "docker_image" {
  type        = string
  description = "Docker image URI from ECR"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "ecr_registry" {
  type        = string
  description = "ECR registry URL"
}

variable "db_host" {
  type        = string
  description = "RDS database host"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
  description = "Database username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password"
}
