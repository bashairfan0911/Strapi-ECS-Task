

output "rds_endpoint" {

  //sh
  value = aws_db_instance.strapi_db.address
}

