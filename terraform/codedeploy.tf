# =============================================================================
# AWS CodeDeploy for ECS Blue/Green Deployment
# =============================================================================

# -----------------------------------------------------------------------------
# IAM Role for CodeDeploy
# -----------------------------------------------------------------------------
resource "aws_iam_role" "codedeploy" {
  name = "codedeploy-ecs-role-irfan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "codedeploy-ecs-role"
    Environment = "production"
  }
}

# Attach AWSCodeDeployRoleForECS managed policy
resource "aws_iam_role_policy_attachment" "codedeploy_ecs" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# Additional permissions for CodeDeploy to manage ECS deployments
resource "aws_iam_role_policy" "codedeploy_ecs_permissions" {
  name = "codedeploy-ecs-additional-permissions"
  role = aws_iam_role.codedeploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:CreateTaskSet",
          "ecs:UpdateServicePrimaryTaskSet",
          "ecs:DeleteTaskSet",
          "ecs:UpdateService",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:ModifyRule"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_execution.arn,
          aws_iam_role.ecs_task.arn
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# CodeDeploy Application
# -----------------------------------------------------------------------------
resource "aws_codedeploy_app" "strapi" {
  name             = "strapi-ecs-app-irfan"
  compute_platform = "ECS"
  # Tags removed due to IAM permission restrictions
}

# -----------------------------------------------------------------------------
# CodeDeploy Deployment Group for ECS Blue/Green
# -----------------------------------------------------------------------------
resource "aws_codedeploy_deployment_group" "strapi" {
  app_name               = aws_codedeploy_app.strapi.name
  deployment_group_name  = "strapi-deployment-group-irfan"
  service_role_arn       = aws_iam_role.codedeploy.arn
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  # ECS Service configuration
  ecs_service {
    cluster_name = aws_ecs_cluster.this.name
    service_name = aws_ecs_service.strapi.name
  }

  # Blue/Green deployment style
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  # Load balancer configuration for traffic shifting
  load_balancer_info {
    target_group_pair_info {
      # Production listener (port 80)
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http.arn]
      }

      # Test listener (port 8080) - for validation before traffic switch
      test_traffic_route {
        listener_arns = [aws_lb_listener.test.arn]
      }

      # Blue Target Group (current production)
      target_group {
        name = aws_lb_target_group.blue.name
      }

      # Green Target Group (new deployment)
      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }

  # Blue/Green deployment configuration
  blue_green_deployment_config {
    # How to handle traffic routing
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    # Terminate old (Blue) instances after successful deployment
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  # Automatic rollback configuration
  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE",
      "DEPLOYMENT_STOP_ON_REQUEST"
    ]
  }

  # Tags removed due to IAM permission restrictions

  depends_on = [
    aws_ecs_service.strapi
  ]
}

# -----------------------------------------------------------------------------
# SNS Topic removed due to IAM permission restrictions
# User lacks SNS:CreateTopic permission
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "codedeploy_app_name" {
  value       = aws_codedeploy_app.strapi.name
  description = "Name of the CodeDeploy Application"
}

output "codedeploy_deployment_group_name" {
  value       = aws_codedeploy_deployment_group.strapi.deployment_group_name
  description = "Name of the CodeDeploy Deployment Group"
}

output "codedeploy_role_arn" {
  value       = aws_iam_role.codedeploy.arn
  description = "ARN of the CodeDeploy IAM Role"
}
