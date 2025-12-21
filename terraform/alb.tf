# Use existing Target Group and ALB ARNs directly
locals {
  strapi_tg_arn     = "arn:aws:elasticloadbalancing:ap-south-1:301782007642:targetgroup/strapi-tg-irfan/5b9f4bfdaa2763b7"
  strapi_alb_arn    = "arn:aws:elasticloadbalancing:ap-south-1:301782007642:loadbalancer/app/strapi-alb-irfan/73119cfcfd58d4c7"
  strapi_alb_dns    = "strapi-alb-irfan-1129106045.ap-south-1.elb.amazonaws.com"
}

# Note: ALB already exists and is managed manually
# This configuration registers it with Terraform state

# Update ECS Security Group to allow public HTTP traffic
resource "aws_security_group_rule" "allow_alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_sg.id
}

# Output ALB DNS Name
output "alb_dns_name" {
  value       = local.strapi_alb_dns
  description = "DNS name of the load balancer"
}

output "alb_url" {
  value       = "http://${local.strapi_alb_dns}"
  description = "URL to access Strapi through the ALB"
}
