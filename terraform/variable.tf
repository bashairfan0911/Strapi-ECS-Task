variable "aws_region" {
  type = string
}

variable "image_uri" {
  type        = string
  description = "Full ECR image URI (passed from CI/CD). If empty, uses ECR repository with 'latest' tag"
  default     = ""
}

# DB variables
variable "db_name" {
  type    = string
  default = "strapidb"
}

variable "db_username" {
  type    = string
  default = "strapi"
}

variable "db_password" {
  type = string
}

variable "log_retention_days" {
  type        = number
  default     = 7
  description = "CloudWatch log retention in days"
}
