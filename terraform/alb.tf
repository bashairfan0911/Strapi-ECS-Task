# =============================================================================
# Application Load Balancer for Blue/Green Deployment
# =============================================================================

# -----------------------------------------------------------------------------
# Application Load Balancer
# -----------------------------------------------------------------------------
resource "aws_lb" "strapi" {
  name               = "strapi-alb-irfan"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.unique_az_subnets  # One subnet per AZ

  enable_deletion_protection = false

  tags = {
    Name        = "strapi-alb"
    Environment = "production"
    Deployment  = "blue-green"
  }
}

# -----------------------------------------------------------------------------
# Target Group - BLUE (Production Traffic)
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "blue" {
  name        = "strapi-tg-blue-irfan"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
  }

  deregistration_delay = 30

  tags = {
    Name        = "strapi-tg-blue"
    Environment = "production"
    Color       = "blue"
  }
}

# -----------------------------------------------------------------------------
# Target Group - GREEN (New Deployment Traffic)
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "green" {
  name        = "strapi-tg-green-irfan"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
  }

  deregistration_delay = 30

  tags = {
    Name        = "strapi-tg-green"
    Environment = "production"
    Color       = "green"
  }
}

# -----------------------------------------------------------------------------
# ALB Listener - Production Traffic (Port 80)
# Routes to Blue Target Group by default
# CodeDeploy will switch traffic between Blue and Green during deployments
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.strapi.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  # Lifecycle to prevent changes during Blue/Green deployments
  lifecycle {
    ignore_changes = [default_action]
  }

  tags = {
    Name = "strapi-listener-http"
  }
}

# -----------------------------------------------------------------------------
# ALB Listener - Test Traffic (Port 8080)
# Used by CodeDeploy to test new deployment before switching production traffic
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.strapi.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  # Lifecycle to prevent changes during Blue/Green deployments
  lifecycle {
    ignore_changes = [default_action]
  }

  tags = {
    Name = "strapi-listener-test"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "alb_dns_name" {
  value       = aws_lb.strapi.dns_name
  description = "DNS name of the load balancer"
}

output "alb_url" {
  value       = "http://${aws_lb.strapi.dns_name}"
  description = "URL to access Strapi through the ALB"
}

output "alb_arn" {
  value       = aws_lb.strapi.arn
  description = "ARN of the ALB"
}

output "blue_target_group_arn" {
  value       = aws_lb_target_group.blue.arn
  description = "ARN of the Blue Target Group"
}

output "green_target_group_arn" {
  value       = aws_lb_target_group.green.arn
  description = "ARN of the Green Target Group"
}

