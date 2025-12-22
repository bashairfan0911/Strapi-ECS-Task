# =============================================================================
# Outputs for Blue/Green Deployment Infrastructure
# =============================================================================

# -----------------------------------------------------------------------------
# RDS Outputs
# -----------------------------------------------------------------------------
output "rds_endpoint" {
  value       = aws_db_instance.strapi_db.address
  description = "RDS Database endpoint"
}

# -----------------------------------------------------------------------------
# Blue/Green Deployment Summary
# -----------------------------------------------------------------------------
output "deployment_info" {
  value = {
    cluster_name        = aws_ecs_cluster.this.name
    service_name        = aws_ecs_service.strapi.name
    codedeploy_app      = aws_codedeploy_app.strapi.name
    deployment_group    = aws_codedeploy_deployment_group.strapi.deployment_group_name
    alb_dns             = aws_lb.strapi.dns_name
    blue_target_group   = aws_lb_target_group.blue.name
    green_target_group  = aws_lb_target_group.green.name
    production_listener = "Port 80"
    test_listener       = "Port 8080"
    deployment_strategy = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  }
  description = "Summary of Blue/Green deployment configuration"
}
