output "instance_id" {
  value       = aws_instance.strapi_ec2.id
  description = "EC2 instance ID"
}

output "public_ip" {
  value       = aws_instance.strapi_ec2.public_ip
  description = "Public IP address of EC2 instance"
}

output "private_ip" {
  value       = aws_instance.strapi_ec2.private_ip
  description = "Private IP address of EC2 instance"
}
