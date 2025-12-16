variable "aws_region" {
  type = string
}

variable "image_uri" {
  type = string
  description = "Full ECR image URI (passed from CI/CD)"
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
  type      = string
}
