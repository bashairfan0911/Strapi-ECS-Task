# CloudWatch Log Group for ECS Strapi Logs
resource "aws_cloudwatch_log_group" "strapi_ecs" {
  name              = "/ecs/strapi"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "strapi-ecs-logs"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# CloudWatch Log Stream for Strapi Container
resource "aws_cloudwatch_log_stream" "strapi_container" {
  name           = "ecs/strapi-container"
  log_group_name = aws_cloudwatch_log_group.strapi_ecs.name
}

# CloudWatch Log Group for RDS Events
resource "aws_cloudwatch_log_group" "rds_events" {
  name              = "/aws/rds/strapi-db"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "strapi-rds-logs"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# CloudWatch Alarm - High CPU Utilization
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "strapi-ecs-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when ECS task CPU exceeds 80%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.this.name
  }

  tags = {
    Name = "strapi-cpu-alarm"
  }
}

# CloudWatch Alarm - High Memory Utilization
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "strapi-ecs-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "Alert when ECS task memory exceeds 85%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.this.name
  }

  tags = {
    Name = "strapi-memory-alarm"
  }
}

# CloudWatch Alarm - Task Count (Unhealthy)
resource "aws_cloudwatch_metric_alarm" "ecs_running_count_low" {
  alarm_name          = "strapi-ecs-running-task-count-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningCount"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alert when no ECS tasks are running"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.this.name
  }

  tags = {
    Name = "strapi-task-count-alarm"
  }
}

# CloudWatch Alarm - RDS CPU Utilization
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "strapi-rds-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Alert when RDS database CPU exceeds 75%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.strapi_db.id
  }

  tags = {
    Name = "strapi-rds-cpu-alarm"
  }
}

# CloudWatch Alarm - RDS Database Connections
resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "strapi-rds-database-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when RDS database connections exceed 80"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.strapi_db.id
  }

  tags = {
    Name = "strapi-rds-connections-alarm"
  }
}

# CloudWatch Dashboard - Strapi Application Monitoring
resource "aws_cloudwatch_dashboard" "strapi_main" {
  dashboard_name = "strapi-application-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", { stat = "Average", label = "ECS CPU %" }],
            [".", "MemoryUtilization", { stat = "Average", label = "ECS Memory %" }],
            [".", "RunningCount", { stat = "Average", label = "Running Tasks" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ECS Task Metrics"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          dimensions = {
            ClusterName = aws_ecs_cluster.this.name
            ServiceName = aws_ecs_service.this.name
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", { stat = "Average", label = "RDS CPU %" }],
            [".", "DatabaseConnections", { stat = "Average", label = "DB Connections" }],
            [".", "DiskQueueDepth", { stat = "Average", label = "Disk Queue Depth" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS Database Metrics"
          yAxis = {
            left = {
              min = 0
            }
          }
          dimensions = {
            DBInstanceIdentifier = aws_db_instance.strapi_db.id
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "NetworkIn", { stat = "Sum", label = "Network In (bytes)" }],
            [".", "NetworkOut", { stat = "Sum", label = "Network Out (bytes)" }]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Network Traffic"
          yAxis = {
            left = {
              min = 0
            }
          }
          dimensions = {
            ClusterName = aws_ecs_cluster.this.name
            ServiceName = aws_ecs_service.this.name
          }
        }
      },
      {
        type = "log"
        properties = {
          query   = "fields @timestamp, @message | filter @message like /ERROR/ | stats count() as error_count by bin(5m)"
          region  = var.aws_region
          title   = "Error Log Count (Last 1 Hour)"
        }
      }
    ]
  })
}

# CloudWatch Dashboard - Application Performance Monitoring
resource "aws_cloudwatch_dashboard" "strapi_performance" {
  dashboard_name = "strapi-performance-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", { stat = "Maximum", label = "Peak CPU" }],
            ["...", { stat = "Minimum", label = "Min CPU" }],
            ["...", { stat = "Average", label = "Avg CPU" }]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "CPU Utilization Trends"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          dimensions = {
            ClusterName = aws_ecs_cluster.this.name
            ServiceName = aws_ecs_service.this.name
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", { stat = "Maximum", label = "Peak Memory" }],
            ["...", { stat = "Minimum", label = "Min Memory" }],
            ["...", { stat = "Average", label = "Avg Memory" }]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "Memory Utilization Trends"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          dimensions = {
            ClusterName = aws_ecs_cluster.this.name
            ServiceName = aws_ecs_service.this.name
          }
        }
      },
      {
        type = "log"
        properties = {
          query   = "fields @duration | stats count() as request_count, avg(@duration) as avg_response_time, max(@duration) as max_response_time by bin(5m)"
          region  = var.aws_region
          title   = "Application Response Times"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections"],
            [".", "NetworkReceiveThroughput"],
            [".", "NetworkTransmitThroughput"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS Network Throughput"
          dimensions = {
            DBInstanceIdentifier = aws_db_instance.strapi_db.id
          }
        }
      }
    ]
  })
}

# Outputs for CloudWatch Resources
output "cloudwatch_log_group_name" {
  value       = aws_cloudwatch_log_group.strapi_ecs.name
  description = "CloudWatch Log Group name for ECS Strapi logs"
}

output "cloudwatch_dashboard_url" {
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.strapi_main.dashboard_name}"
  description = "URL to CloudWatch Dashboard"
}

output "cloudwatch_alarms" {
  value = {
    cpu_high                = aws_cloudwatch_metric_alarm.ecs_cpu_high.alarm_name
    memory_high             = aws_cloudwatch_metric_alarm.ecs_memory_high.alarm_name
    task_count_low          = aws_cloudwatch_metric_alarm.ecs_running_count_low.alarm_name
    rds_cpu_high            = aws_cloudwatch_metric_alarm.rds_cpu_high.alarm_name
    rds_connections_high    = aws_cloudwatch_metric_alarm.rds_connections_high.alarm_name
  }
  description = "CloudWatch Alarms created for monitoring"
}
