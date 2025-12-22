# =============================================================================
# Security Groups for Blue/Green Deployment
# =============================================================================

# -----------------------------------------------------------------------------
# ALB Security Group - Allows HTTP (80), HTTPS (443), and Test (8080) traffic
# -----------------------------------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "strapi-alb-sg-irfan"
  description = "Security group for Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  # HTTP traffic (Production)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS traffic
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Test traffic (for CodeDeploy Blue/Green validation)
  ingress {
    description = "Test listener for Blue/Green deployments"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "strapi-alb-sg"
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# ECS Security Group - Allows traffic from ALB on port 1337
# -----------------------------------------------------------------------------
resource "aws_security_group" "ecs_sg" {
  name        = "strapi-ecs-sg-ap"
  description = "Allow Strapi traffic from ALB to ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  # Allow traffic from ALB on Strapi port
  ingress {
    description     = "Strapi HTTP from ALB"
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "strapi-ecs-sg"
    Environment = "production"
  }
}

# -----------------------------------------------------------------------------
# RDS Security Group - Allows traffic from ECS tasks on port 5432
# -----------------------------------------------------------------------------
resource "aws_security_group" "rds_sg" {
  name        = "irfan-rds-sg-ap"
  description = "Allow DB access from ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Postgres from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "irfan-rds-sg"
    Environment = "production"
  }
}
