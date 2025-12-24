# =============================================================================
# CloudWatch Resources - COMMENTED OUT
# =============================================================================
# Uncomment these resources when you want to enable CloudWatch monitoring
# =============================================================================

# # CloudWatch Log Group for ECS Strapi Logs
# resource "aws_cloudwatch_log_group" "strapi_ecs" {
#   name              = "/ecs/strapi"
#   retention_in_days = var.log_retention_days
#
#   tags = {
#     Name        = "strapi-ecs-logs"
#     Environment = "production"
#     ManagedBy   = "terraform"
#   }
# }
#
# # CloudWatch Log Stream for Strapi Container
# resource "aws_cloudwatch_log_stream" "strapi_container" {
#   name           = "ecs/strapi-container"
#   log_group_name = aws_cloudwatch_log_group.strapi_ecs.name
# }
#
# # CloudWatch Log Group for RDS Events
# resource "aws_cloudwatch_log_group" "rds_events" {
#   name              = "/aws/rds/strapi-db"
#   retention_in_days = var.log_retention_days
#
#   tags = {
#     Name        = "strapi-rds-logs"
#     Environment = "production"
#     ManagedBy   = "terraform"
#   }
# }

# # CloudWatch Alarm - High CPU Utilization
# resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
#   alarm_name          = "strapi-ecs-cpu-utilization-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ECS"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 80
#   alarm_description   = "Alert when ECS task CPU exceeds 80%"
#   treat_missing_data  = "notBreaching"
#
#   dimensions = {
#     ClusterName = aws_ecs_cluster.this.name
#     ServiceName = aws_ecs_service.strapi.name
#   }
#
#   tags = {
#     Name = "strapi-cpu-alarm"
#   }
# }
#
# # CloudWatch Alarm - High Memory Utilization
# resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
#   alarm_name          = "strapi-ecs-memory-utilization-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "MemoryUtilization"
#   namespace           = "AWS/ECS"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 85
#   alarm_description   = "Alert when ECS task memory exceeds 85%"
#   treat_missing_data  = "notBreaching"
#
#   dimensions = {
#     ClusterName = aws_ecs_cluster.this.name
#     ServiceName = aws_ecs_service.strapi.name
#   }
#
#   tags = {
#     Name = "strapi-memory-alarm"
#   }
# }
#
# # CloudWatch Alarm - Task Count (Unhealthy)
# resource "aws_cloudwatch_metric_alarm" "ecs_running_count_low" {
#   alarm_name          = "strapi-ecs-running-task-count-low"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = 1
#   metric_name         = "RunningCount"
#   namespace           = "AWS/ECS"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 1
#   alarm_description   = "Alert when no ECS tasks are running"
#   treat_missing_data  = "notBreaching"
#
#   dimensions = {
#     ClusterName = aws_ecs_cluster.this.name
#     ServiceName = aws_ecs_service.strapi.name
#   }
#
#   tags = {
#     Name = "strapi-task-count-alarm"
#   }
# }

# # CloudWatch Alarm - RDS CPU Utilization
# resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
#   alarm_name          = "strapi-rds-cpu-utilization-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/RDS"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 75
#   alarm_description   = "Alert when RDS database CPU exceeds 75%"
#   treat_missing_data  = "notBreaching"
#
#   dimensions = {
#     DBInstanceIdentifier = aws_db_instance.strapi_db.id
#   }
#
#   tags = {
#     Name = "strapi-rds-cpu-alarm"
#   }
# }
#
# # CloudWatch Alarm - RDS Database Connections
# resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
#   alarm_name          = "strapi-rds-database-connections-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "DatabaseConnections"
#   namespace           = "AWS/RDS"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 80
#   alarm_description   = "Alert when RDS database connections exceed 80"
#   treat_missing_data  = "notBreaching"
#
#   dimensions = {
#     DBInstanceIdentifier = aws_db_instance.strapi_db.id
#   }
#
#   tags = {
#     Name = "strapi-rds-connections-alarm"
#   }
# }

# # CloudWatch Dashboard - Strapi Application Monitoring
# resource "aws_cloudwatch_dashboard" "strapi_main" {
#   dashboard_name = "strapi-application-monitoring"
#
#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         type   = "metric"
#         x      = 0
#         y      = 0
#         width  = 6
#         height = 6
#         properties = {
#           metrics = [
#             ["AWS/ECS", "CPUUtilization", "ClusterName", "${aws_ecs_cluster.this.name}", "ServiceName", "${aws_ecs_service.strapi.name}", { label = "ECS CPU %" }],
#             ["AWS/ECS", "MemoryUtilization", "ClusterName", "${aws_ecs_cluster.this.name}", "ServiceName", "${aws_ecs_service.strapi.name}", { label = "ECS Memory %" }]
#           ]
#           period = 300
#           stat   = "Average"
#           region = var.aws_region
#           title  = "ECS Task Metrics"
#           yAxis = {
#             left = {
#               min = 0
#               max = 100
#             }
#           }
#         }
#       },
#       {
#         type   = "metric"
#         x      = 6
#         y      = 0
#         width  = 6
#         height = 6
#         properties = {
#           metrics = [
#             ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${aws_db_instance.strapi_db.identifier}", { label = "RDS CPU %" }],
#             ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${aws_db_instance.strapi_db.identifier}", { label = "DB Connections" }],
#             ["AWS/RDS", "DiskQueueDepth", "DBInstanceIdentifier", "${aws_db_instance.strapi_db.identifier}", { label = "Disk Queue Depth" }]
#           ]
#           period = 300
#           stat   = "Average"
#           region = var.aws_region
#           title  = "RDS Database Metrics"
#           yAxis = {
#             left = {
#               min = 0
#             }
#           }
#         }
#       },
#       {
#         type   = "metric"
#         x      = 12
#         y      = 0
#         width  = 6
#         height = 6
#         properties = {
#           metrics = [
#             ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_lb.strapi.arn_suffix}", { label = "Request Count", stat = "Sum" }],
#             ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", "${aws_lb.strapi.arn_suffix}", { label = "2XX Responses", stat = "Sum" }]
#           ]
#           period = 300
#           stat   = "Sum"
#           region = var.aws_region
#           title  = "ALB Traffic"
#           yAxis = {
#             left = {
#               min = 0
#             }
#           }
#         }
#       },
#       {
#         type   = "metric"
#         x      = 18
#         y      = 0
#         width  = 6
#         height = 6
#         properties = {
#           metrics = [
#             ["ECS/ContainerInsights", "DesiredTaskCount", "ClusterName", "${aws_ecs_cluster.this.name}", "ServiceName", "${aws_ecs_service.strapi.name}", { label = "Desired Tasks" }],
#             ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", "${aws_ecs_cluster.this.name}", "ServiceName", "${aws_ecs_service.strapi.name}", { label = "Running Tasks" }]
#           ]
#           period = 300
#           stat   = "Average"
#           region = var.aws_region
#           title  = "Task Deployment Status"
#           yAxis = {
#             left = {
#               min = 0
#             }
#           }
#         }
#       }
#     ]
#   })
# }

# # CloudWatch Dashboard - Application Performance Monitoring
# resource "aws_cloudwatch_dashboard" "strapi_performance" {
#   dashboard_name = "strapi-performance-monitoring"
#
#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         type   = "metric"
#         x      = 0
#         y      = 0
#         width  = 12
#         height = 6
#         properties = {
#           metrics = [
#             ["AWS/ECS", "CPUUtilization", "ClusterName", "${aws_ecs_cluster.this.name}", "ServiceName", "${aws_ecs_service.strapi.name}", { stat = "Maximum", label = "Peak CPU" }],
#             ["AWS/ECS", "CPUUtilization", "ClusterName", "${aws_ecs_cluster.this.name}", "ServiceName", "${aws_ecs_service.strapi.name}", { stat = "Minimum", label = "Min CPU" }],
#             ["AWS/ECS", "CPUUtilization", "ClusterName", "${aws_ecs_cluster.this.name}", "ServiceName", "${aws_ecs_service.strapi.name}", { stat = "Average", label = "Avg CPU" }]
#           ]
#           period = 60
#           region = var.aws_region
#           title  = "CPU Utilization Trends"
#           yAxis = {
#             left = {
#               min = 0
#               max = 100
#             }
#           }
#         }
#       },
#       {
#         type   = "metric"
#         x      = 12
#         y      = 0
#         width  = 12
#         height = 6
#         properties = {
#           metrics = [
#             ["AWS/ECS", "MemoryUtilization", "ClusterName", "${aws_ecs_cluster.this.name}", "ServiceName", "${aws_ecs_service.strapi.name}", { stat = "Maximum", label = "Peak Memory" }],
#             ["AWS/ECS", "MemoryUtilization", "ClusterName", "${aws_ecs_cluster.this.name}", "ServiceName", "${aws_ecs_service.strapi.name}", { stat = "Minimum", label = "Min Memory" }],
#             ["AWS/ECS", "MemoryUtilization", "ClusterName", "${aws_ecs_cluster.this.name}", "ServiceName", "${aws_ecs_service.strapi.name}", { stat = "Average", label = "Avg Memory" }]
#           ]
#           period = 60
#           region = var.aws_region
#           title  = "Memory Utilization Trends"
#           yAxis = {
#             left = {
#               min = 0
#               max = 100
#             }
#           }
#         }
#       },
#       {
#         type   = "metric"
#         x      = 0
#         y      = 6
#         width  = 12
#         height = 6
#         properties = {
#           metrics = [
#             ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_lb.strapi.arn_suffix}", "TargetGroup", "${aws_lb_target_group.blue.arn_suffix}", { stat = "Average", label = "Blue Avg Response" }],
#             ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_lb.strapi.arn_suffix}", "TargetGroup", "${aws_lb_target_group.green.arn_suffix}", { stat = "Average", label = "Green Avg Response" }],
#             ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_lb.strapi.arn_suffix}", { stat = "Sum", label = "Total Requests", yAxis = "right" }]
#           ]
#           period = 300
#           region = var.aws_region
#           title  = "Application Response Times"
#           yAxis = {
#             left = {
#               label = "Response Time (seconds)"
#               min = 0
#             }
#             right = {
#               label = "Request Count"
#               min = 0
#             }
#           }
#         }
#       },
#       {
#         type   = "metric"
#         x      = 12
#         y      = 6
#         width  = 12
#         height = 6
#         properties = {
#           metrics = [
#             ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${aws_db_instance.strapi_db.identifier}", { label = "Connections" }],
#             ["AWS/RDS", "NetworkReceiveThroughput", "DBInstanceIdentifier", "${aws_db_instance.strapi_db.identifier}", { label = "Network In" }],
#             ["AWS/RDS", "NetworkTransmitThroughput", "DBInstanceIdentifier", "${aws_db_instance.strapi_db.identifier}", { label = "Network Out" }]
#           ]
#           period = 300
#           stat   = "Average"
#           region = var.aws_region
#           title  = "RDS Network Throughput"
#         }
#       }
#     ]
#   })
# }
#
# # Outputs for CloudWatch Resources
# output "cloudwatch_log_group_name" {
#   value       = aws_cloudwatch_log_group.strapi_ecs.name
#   description = "CloudWatch Log Group name for ECS Strapi logs"
# }
#
# output "cloudwatch_dashboard_url" {
#   value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.strapi_main.dashboard_name}"
#   description = "URL to CloudWatch Dashboard"
# }
#
# output "cloudwatch_alarms" {
#   value = {
#     cpu_high             = aws_cloudwatch_metric_alarm.ecs_cpu_high.alarm_name
#     memory_high          = aws_cloudwatch_metric_alarm.ecs_memory_high.alarm_name
#     task_count_low       = aws_cloudwatch_metric_alarm.ecs_running_count_low.alarm_name
#     rds_cpu_high         = aws_cloudwatch_metric_alarm.rds_cpu_high.alarm_name
#     rds_connections_high = aws_cloudwatch_metric_alarm.rds_connections_high.alarm_name
#   }
#   description = "CloudWatch Alarms created for monitoring"
# }
