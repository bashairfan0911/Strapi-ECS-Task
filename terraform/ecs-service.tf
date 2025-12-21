# ECS Service with ALB Integration using Fargate Spot
resource "aws_ecs_service" "strapi" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1

  # Force new deployment when switching capacity providers
  force_new_deployment = true

  # Use capacity provider strategy for Fargate Spot (up to 70% cost savings)
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
    base              = 1
  }

  network_configuration {
    subnets          = data.aws_subnets.default_vpc_subnets.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = local.strapi_tg_arn
    container_name   = "strapi"
    container_port   = 1337
  }

  tags = {
    Name = "strapi-service"
  }
}
