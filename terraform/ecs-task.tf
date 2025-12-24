# =============================================================================
# ECS Task Definition for Blue/Green Deployment
# =============================================================================
# This task definition serves as a placeholder and will be updated dynamically
# by CodeDeploy during Blue/Green deployments via CI/CD pipeline

# Local to determine image URI
locals {
  # Use provided image_uri or default to ECR repository with latest tag
  container_image = var.image_uri != "" ? var.image_uri : "${aws_ecr_repository.strapi.repository_url}:latest"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = local.container_image
      essential = true

      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/strapi"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs/strapi"
          awslogs-create-group  = "true"
        }
      }

      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "DATABASE_CLIENT", value = "postgres" },
        { name = "DATABASE_HOST", value = aws_db_instance.strapi_db.address },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = var.db_name },
        { name = "DATABASE_USERNAME", value = var.db_username },
        { name = "DATABASE_PASSWORD", value = var.db_password },
        { name = "ADMIN_JWT_SECRET", value = "changeme-super-secret-admin-jwt" },
        { name = "JWT_SECRET", value = "your-jwt-secret-key-here-change-me" },
        { name = "APP_KEYS", value = "key1,key2,key3,key4" },
        { name = "API_TOKEN_SALT", value = "change-me-api-salt-123" },
        { name = "TRANSFER_TOKEN_SALT", value = "change-me-transfer-salt-456" },
        { name = "ENCRYPTION_KEY", value = "change-me-encryption-key-789" },
        { name = "STRAPI_DISABLE_ADMIN", value = "false" },
        { name = "STRAPI_DISABLE_UPDATE_NOTIFICATION", value = "true" },
        { name = "STRAPI_TELEMETRY_DISABLED", value = "true" }
      ]
    }
  ])

  tags = {
    Name        = "strapi-task-definition"
    Environment = "production"
    Deployment  = "blue-green"
  }

  # Lifecycle to allow CodeDeploy to manage task definition updates
  lifecycle {
    create_before_destroy = true
  }
}

# Output task definition ARN for CodeDeploy
output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "ARN of the ECS Task Definition"
}

output "task_definition_family" {
  value       = aws_ecs_task_definition.this.family
  description = "Family name of the ECS Task Definition"
}
