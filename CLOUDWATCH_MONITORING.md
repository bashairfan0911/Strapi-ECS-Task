# 📊 CloudWatch Monitoring Guide for Strapi ECS

## Overview

This guide explains how CloudWatch monitoring has been integrated into your Strapi ECS deployment for comprehensive logging, metrics collection, and alerting.

---

## 🏗️ CloudWatch Infrastructure

### CloudWatch Components Deployed

#### 1. **Log Groups**
- **Primary Log Group:** `/ecs/strapi` - All Strapi container logs
- **RDS Log Group:** `/aws/rds/strapi-db` - Database events
- **Log Retention:** 7 days (configurable via `terraform/variable.tf`)

#### 2. **Log Streams**
- **Stream:** `ecs/strapi-container` - Container application logs

#### 3. **Metrics**
CloudWatch automatically collects these ECS metrics:
- **CPU Utilization** - % of CPU used by task
- **Memory Utilization** - % of memory used by task
- **Running Count** - Number of running tasks
- **Network In/Out** - Bytes transmitted/received

RDS Metrics:
- **CPU Utilization** - % of CPU used by database
- **Database Connections** - Active connections
- **Disk Queue Depth** - I/O queue depth
- **Network Throughput** - Network in/out bytes

#### 4. **CloudWatch Alarms**
Automated alerts for:
- ✅ High ECS CPU (>80%)
- ✅ High ECS Memory (>85%)
- ✅ Low Task Count (no tasks running)
- ✅ High RDS CPU (>75%)
- ✅ High RDS Connections (>80)

#### 5. **CloudWatch Dashboards**
- **Main Dashboard:** `strapi-application-monitoring` - ECS and RDS metrics
- **Performance Dashboard:** `strapi-performance-monitoring` - Trends and response times

---

## 🚀 Accessing CloudWatch

### CloudWatch Console

#### View Logs
```
AWS Console → CloudWatch → Log Groups → /ecs/strapi
```

**To search logs:**
```
AWS Console → CloudWatch → Log Groups → /ecs/strapi → Log Streams → ecs/strapi-container
```

#### View Metrics
```
AWS Console → CloudWatch → Metrics → ECS/AWS → By Cluster Name
```

#### View Dashboards
```
AWS Console → CloudWatch → Dashboards → strapi-application-monitoring
```

#### View Alarms
```
AWS Console → CloudWatch → Alarms
```

### AWS CLI Commands

#### Tail logs in real-time
```bash
aws logs tail /ecs/strapi --follow --region ap-south-1
```

#### Get last 100 log events
```bash
aws logs tail /ecs/strapi --max-items 100 --region ap-south-1
```

#### Search for errors
```bash
aws logs filter-log-events \
  --log-group-name /ecs/strapi \
  --filter-pattern "ERROR" \
  --region ap-south-1
```

#### Get latest metric data
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ClusterName,Value=strapi-ecs-irfan-cluster \
                Name=ServiceName,Value=strapi-service \
  --start-time 2025-12-17T00:00:00Z \
  --end-time 2025-12-17T23:59:59Z \
  --period 300 \
  --statistics Average,Maximum \
  --region ap-south-1
```

#### List all alarms
```bash
aws cloudwatch describe-alarms --region ap-south-1
```

#### Get alarm history
```bash
aws cloudwatch describe-alarm-history \
  --alarm-name strapi-ecs-cpu-utilization-high \
  --region ap-south-1
```

---

## 📈 Understanding the Dashboards

### Main Dashboard: `strapi-application-monitoring`

**Widget 1: ECS Task Metrics**
- Displays CPU%, Memory%, and Running Task Count
- **What to watch:**
  - CPU spike → Check for resource-heavy operations
  - Memory increase → May need to scale up task memory
  - Task count drop → Service may be unhealthy

**Widget 2: RDS Database Metrics**
- Displays CPU%, Database Connections, Disk Queue Depth
- **What to watch:**
  - High connections → May need connection pooling
  - High queue depth → Disk I/O bottleneck
  - CPU spike → Query optimization needed

**Widget 3: Network Traffic**
- Shows Network In/Out bytes
- **What to watch:**
  - Sudden spikes → DDoS or traffic surge
  - High outbound → Large response sizes

**Widget 4: Error Log Count**
- Aggregates ERROR level logs per 5 minutes
- **What to watch:**
  - Any errors in production should be investigated

---

## 🚨 Alarms Explained

### CPU Utilization Alarm (ECS)
```
Threshold: 80% over 10 minutes (2 x 300s)
Action: Alert when exceeded
Purpose: Prevent resource exhaustion
```

**When triggered:**
- May need to increase task memory/CPU
- May need to optimize application code
- Consider scaling to multiple tasks

### Memory Utilization Alarm (ECS)
```
Threshold: 85% over 10 minutes (2 x 300s)
Action: Alert when exceeded
Purpose: Prevent out-of-memory crashes
```

**When triggered:**
- Update task definition with more memory
- Check for memory leaks in application
- Redeploy: `terraform apply -auto-approve`

### Task Count Alarm
```
Threshold: 0 running tasks
Action: Alert immediately
Purpose: Detect service failures
```

**When triggered:**
- Service has crashed
- Check ECS logs: `aws logs tail /ecs/strapi --follow`
- May need to restart service or increase task capacity

### RDS CPU Alarm
```
Threshold: 75% over 10 minutes
Action: Alert when exceeded
Purpose: Prevent database performance degradation
```

**When triggered:**
- Check slow queries in RDS logs
- May need to optimize database indices
- Consider increasing RDS instance class

### RDS Connections Alarm
```
Threshold: 80 connections
Action: Alert when exceeded
Purpose: Prevent connection exhaustion
```

**When triggered:**
- Too many simultaneous connections
- Implement connection pooling
- Check for connection leaks in application

---

## 📊 Monitoring Best Practices

### Daily Checks
```
1. Check CloudWatch Dashboard for trends
2. Review error logs for issues
3. Monitor CPU and memory trends
4. Ensure all tasks are running
```

### Weekly Reviews
```
1. Analyze performance metrics
2. Review alarm history
3. Optimize based on usage patterns
4. Plan scaling if needed
```

### Monthly Audits
```
1. Review log retention policies
2. Optimize alarm thresholds
3. Clean up old logs
4. Analyze cost trends
```

---

## 🔧 Customizing Alerts

### To change alarm thresholds:

Edit `terraform/cloudwatch.tf`:

```hcl
# Example: Increase CPU threshold to 90%
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  threshold = 90  # Changed from 80
  # ... rest of config
}
```

Then apply:
```bash
cd terraform
terraform apply -auto-approve
```

### To add custom alarms:

Add to `terraform/cloudwatch.tf`:

```hcl
resource "aws_cloudwatch_metric_alarm" "custom_alarm" {
  alarm_name          = "my-custom-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  
  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.this.name
  }
}
```

---

## 📝 Interpreting Common Patterns

### Pattern 1: High CPU at specific times
**Cause:** Scheduled batch jobs or peak traffic
**Action:** Review what's happening at that time, consider auto-scaling

### Pattern 2: Memory slowly increasing
**Cause:** Memory leak in application
**Action:** Restart task, review application code, check for leaks

### Pattern 3: Network spikes without load
**Cause:** May indicate data exfiltration
**Action:** Review security logs, check for unauthorized access

### Pattern 4: Connection spikes
**Cause:** Query storms, slow queries blocking connections
**Action:** Optimize database, add connection pooling, increase task count

---

## 🔍 Troubleshooting with CloudWatch

### Issue: "Task exited with exit code 137"
```bash
# This is OOM Kill (Out of Memory)
# Check memory logs:
aws logs filter-log-events \
  --log-group-name /ecs/strapi \
  --filter-pattern "137"

# Solution: Increase task memory in ecs-task.tf
memory = 2048  # Increase from 1024
```

### Issue: "CannotPullContainerImage"
```bash
# Check logs for image pull errors:
aws logs filter-log-events \
  --log-group-name /ecs/strapi \
  --filter-pattern "CannotPull"

# Verify image in ECR:
aws ecr describe-images --repository-name irfan-strapi-image
```

### Issue: "Database connection timeout"
```bash
# Check RDS logs:
aws logs tail /aws/rds/strapi-db --follow

# Verify RDS is running:
aws rds describe-db-instances \
  --db-instance-identifier strapidb-irfan-ap
```

---

## 📲 Setting Up Notifications (Optional)

### Via SNS (Simple Notification Service):

```hcl
# Add to terraform/cloudwatch.tf

resource "aws_sns_topic" "strapi_alerts" {
  name = "strapi-alerts"
}

resource "aws_sns_topic_subscription" "strapi_alerts_email" {
  topic_arn = aws_sns_topic.strapi_alerts.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"
}

# Add to alarms:
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  # ... existing config ...
  alarm_actions = [aws_sns_topic.strapi_alerts.arn]
}
```

Then apply:
```bash
terraform apply -auto-approve
```

---

## 📊 Sample Log Queries

### Find all errors in last hour
```
fields @timestamp, @message 
| filter @message like /ERROR/
| sort @timestamp desc
```

### Count requests by status code
```
fields @message, statusCode
| filter statusCode > 0
| stats count() as count by statusCode
```

### Average response time per endpoint
```
fields @duration, endpoint
| stats avg(@duration) as avg_time by endpoint
```

### Database query performance
```
fields @duration
| filter @message like /query/
| stats avg(@duration), max(@duration), count() by bin(5m)
```

---

## 🎯 Monitoring Checklist

- [ ] CloudWatch Log Groups created (`/ecs/strapi`)
- [ ] ECS Task Definition configured with CloudWatch logging
- [ ] All required metrics being collected
- [ ] Alarms configured and tested
- [ ] Dashboards set up and accessible
- [ ] Log retention policy set (7 days)
- [ ] IAM role has CloudWatch permissions
- [ ] Team access to CloudWatch Console configured
- [ ] Notification alerts configured (optional)
- [ ] Regular monitoring schedule established

---

## 💰 CloudWatch Pricing

**Costs for your deployment:**
- **Logs ingestion:** ~$0.50/GB ingested
- **Logs storage:** ~$0.03/GB/month (7-day retention)
- **Metrics:** ~$0.10 per custom metric per month
- **Dashboard:** Free (first 3 dashboards)
- **Alarms:** ~$0.10 per alarm per month

**Estimated monthly cost:** $5-15

---

## 📚 Additional Resources

- **AWS CloudWatch Docs:** https://docs.aws.amazon.com/cloudwatch/
- **ECS Metrics:** https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/cloudwatch-limits-eventbridge.html
- **CloudWatch Insights:** https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html
- **Terraform CloudWatch:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group

---

**Status:** ✅ CloudWatch monitoring fully integrated with Strapi ECS deployment

Last Updated: December 17, 2025
