# =============================================================================
# ECS Cluster for Blue/Green Deployment
# =============================================================================

resource "aws_ecs_cluster" "this" {
  name = "strapi-ecs-irfan-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "strapi-ecs-cluster"
    Environment = "production"
    Deployment  = "blue-green"
  }
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
