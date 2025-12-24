# =============================================================================
# ECS Service for Blue/Green Deployment with CodeDeploy
# =============================================================================

resource "aws_ecs_service" "strapi" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 2 # Run 2 tasks for high availability

  # Use Fargate launch type for Blue/Green deployments
  launch_type = "FARGATE"

  # Platform version (use LATEST for newest Fargate features)
  platform_version = "1.4.0"

  # Deployment controller set to CODE_DEPLOY for Blue/Green deployments
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # Network configuration for Fargate
  network_configuration {
    subnets          = local.all_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  # Initial load balancer configuration - Blue Target Group
  # CodeDeploy will manage switching between Blue and Green
  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  # Health check grace period to allow container to start
  health_check_grace_period_seconds = 120

  # Propagate tags from service to tasks
  propagate_tags = "SERVICE"

  # Enable ECS managed tags
  enable_ecs_managed_tags = true

  tags = {
    Name        = "strapi-service"
    Environment = "production"
    Deployment  = "blue-green"
  }

  # Lifecycle to prevent Terraform from managing deployments
  # CodeDeploy will handle task definition and target group changes
  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer,
      desired_count
    ]
  }

  # Ensure ALB resources are created first
  depends_on = [
    aws_lb_listener.http,
    aws_lb_listener.test
  ]
}

# Output ECS Service details
output "ecs_service_name" {
  value       = aws_ecs_service.strapi.name
  description = "Name of the ECS Service"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "Name of the ECS Cluster"
}
