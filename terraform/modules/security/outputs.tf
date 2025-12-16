output "strapi_sg_id" {
  value       = aws_security_group.strapi_sg.id
  description = "Security group ID for Strapi EC2 instance"
}

output "rds_sg_id" {
  value       = aws_security_group.rds_sg.id
  description = "Security group ID for RDS instance"
}
