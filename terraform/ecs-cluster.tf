resource "aws_ecs_cluster" "this" {
  // Cluster for Strapi application
  name = "strapi-ecs-irfan-cluster"  // Cluster name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
