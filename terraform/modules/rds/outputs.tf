output "db_endpoint" {
  value       = aws_db_instance.strapi_db.address
  description = "RDS database endpoint"
}

output "db_port" {
  value       = aws_db_instance.strapi_db.port
  description = "RDS database port"
}

output "db_name" {
  value       = aws_db_instance.strapi_db.db_name
  description = "Database name"
}
