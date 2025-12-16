terraform {
  backend "s3" {
    bucket  = "irfan-terraform-state-20251216172226"
    key     = "strapi/terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true
  }
}
