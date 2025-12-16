output "strapi_url" {
  value       = "http://${module.ec2.public_ip}:1337"
  description = "Strapi application URL"
}

output "strapi_admin_url" {
  value       = "http://${module.ec2.public_ip}:1337/admin"
  description = "Strapi admin panel URL"
}

output "ec2_instance_id" {
  value       = module.ec2.instance_id
  description = "EC2 instance ID"
}

output "ec2_public_ip" {
  value       = module.ec2.public_ip
  description = "EC2 public IP address"
}

output "rds_endpoint" {
  value       = module.rds.db_endpoint
  description = "RDS database endpoint"
}

output "rds_port" {
  value       = module.rds.db_port
  description = "RDS database port"
}

