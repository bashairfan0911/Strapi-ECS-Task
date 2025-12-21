# Quick Reference Guide - Strapi ECS Deployment

## 🎯 Current Status: ✅ ACTIVE

| Component | Status | Details |
|-----------|--------|---------|
| ECS Service | ✅ ACTIVE | 1/1 tasks running |
| Task Definition | ✅ v11 | Strapi development mode |
| Database | ✅ ACTIVE | PostgreSQL 14 |
| CloudWatch | ✅ ACTIVE | Logs & 5 Alarms |
| ALB | ✅ CREATED | DNS ready |

---

## 📍 Access Points

### Primary Access (Direct)
```
http://13.203.218.20:1337/admin
```

### Load Balancer (Recommended - ready for production)
```
http://strapi-alb-irfan-1129106045.ap-south-1.elb.amazonaws.com
```

---

## 📊 CloudWatch Dashboards

1. **Application Monitoring**
   - ECS CPU, Memory, Task Count, Network metrics
   - [Open Dashboard](https://console.aws.amazon.com/cloudwatch/home?region=ap-south-1#dashboards:name=strapi-application-monitoring)

2. **Performance Monitoring**
   - RDS CPU, Connections, Disk Queue
   - [View Dashboard](https://console.aws.amazon.com/cloudwatch/home?region=ap-south-1#dashboards:name=strapi-performance-monitoring)

---

## 🔍 Monitoring Commands

### View Recent Logs
```bash
aws logs tail /ecs/strapi --follow --region ap-south-1
```

### Check Service Status
```bash
aws ecs describe-services \
  --cluster strapi-ecs-irfan-cluster \
  --services strapi-service \
  --region ap-south-1
```

### View Active Alarms
```bash
aws cloudwatch describe-alarms \
  --region ap-south-1 \
  --query 'MetricAlarms[?StateValue==`ALARM`]'
```

### Get Task IP Address
```bash
aws ecs list-tasks \
  --cluster strapi-ecs-irfan-cluster \
  --service-name strapi-service \
  --region ap-south-1 | grep -o 'arn:aws:ecs[^"]*' | xargs -I {} \
aws ecs describe-tasks \
  --cluster strapi-ecs-irfan-cluster \
  --tasks {} \
  --region ap-south-1 \
  --query 'tasks[0].containerInstanceArn'
```

---

## 🚀 Deployment Commands

### Deploy Changes
```bash
cd d:\STRAPI_ECS\terraform
terraform plan -var="log_retention_days=7"
terraform apply -auto-approve -var="log_retention_days=7"
```

### Force Service Restart
```bash
aws ecs update-service \
  --cluster strapi-ecs-irfan-cluster \
  --service strapi-service \
  --force-new-deployment \
  --region ap-south-1
```

### Scale to Multiple Tasks
```bash
aws ecs update-service \
  --cluster strapi-ecs-irfan-cluster \
  --service strapi-service \
  --desired-count 2 \
  --region ap-south-1
```

---

## 🛠️ AWS Resources

| Resource | Name | Region |
|----------|------|--------|
| ECS Cluster | `strapi-ecs-irfan-cluster` | ap-south-1 |
| ECS Service | `strapi-service` | ap-south-1 |
| Task Definition | `strapi-task:11` | ap-south-1 |
| ALB | `strapi-alb-irfan` | ap-south-1 |
| Target Group | `strapi-tg-irfan` | ap-south-1 |
| RDS Database | `strapidb-irfan-ap` | ap-south-1 |
| Security Groups | `sg-0defcd262a63b3e85` (ECS) | ap-south-1 |
|  | `sg-0d957603d23771564` (RDS) | ap-south-1 |
| Log Group | `/ecs/strapi` | ap-south-1 |

---

## 🔐 Environment Variables (Task Definition)

```env
NODE_ENV=development
DATABASE_CLIENT=postgres
DATABASE_HOST=strapidb-irfan-ap.cbowmc0uim96.ap-south-1.rds.amazonaws.com
DATABASE_PORT=5432
DATABASE_NAME=strapidb
DATABASE_USERNAME=strapi
DATABASE_SSL=false
ADMIN_JWT_SECRET=changeme-super-secret-admin-jwt
JWT_SECRET=changeme-super-secret-jwt-secret
API_TOKEN_SALT=changeme-super-secret-api-token-salt
STRAPI_DISABLE_ADMIN=false
STRAPI_HOST=0.0.0.0
STRAPI_PORT=1337
```

---

## 📋 CloudWatch Alarms

| Alarm | Threshold | Status |
|-------|-----------|--------|
| `strapi-ecs-cpu-utilization-high` | > 80% | Enabled |
| `strapi-ecs-memory-utilization-high` | > 80% | Enabled |
| `strapi-ecs-running-task-count-low` | < 1 | Enabled |
| `strapi-rds-cpu-utilization-high` | > 80% | Enabled |
| `strapi-rds-database-connections-high` | > 50 | Enabled |

---

## 🐳 Docker Image

**URI**: `301782007642.dkr.ecr.ap-south-1.amazonaws.com/irfan-strapi-image:latest`

To update image:
```bash
# Build and push
docker build -t irfan-strapi-image:latest .
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 301782007642.dkr.ecr.ap-south-1.amazonaws.com
docker tag irfan-strapi-image:latest 301782007642.dkr.ecr.ap-south-1.amazonaws.com/irfan-strapi-image:latest
docker push 301782007642.dkr.ecr.ap-south-1.amazonaws.com/irfan-strapi-image:latest

# Redeploy
aws ecs update-service --cluster strapi-ecs-irfan-cluster --service strapi-service --force-new-deployment --region ap-south-1
```

---

## 🔄 Infrastructure as Code

**Terraform State**: Stored in S3 backend (configured in provider.tf)

### Key Files
- `terraform/ecs-cluster.tf` - ECS cluster
- `terraform/ecs-task.tf` - Task definition
- `terraform/ecs-service.tf` - Service configuration
- `terraform/rds.tf` - Database
- `terraform/cloudwatch.tf` - Monitoring
- `terraform/alb.tf` - Load balancer
- `terraform/security.tf` - Security groups
- `terraform/iam.tf` - IAM roles

---

## 🚨 Troubleshooting

### Service Won't Start
1. Check ECS service events: `aws ecs describe-services ...`
2. Review CloudWatch logs: `aws logs tail /ecs/strapi`
3. Check RDS connectivity
4. Verify security groups allow traffic

### High Resource Usage
1. View metrics in CloudWatch dashboards
2. Check application logs for errors
3. Consider scaling up task resources
4. Scale horizontally (increase desired_count)

### Database Connection Issues
1. Verify RDS endpoint in environment variables
2. Check security group rules (ECS → RDS on port 5432)
3. Verify database credentials
4. Test from ECS task container

---

## 📞 Support

For detailed information, see `DEPLOYMENT_SUMMARY.md`

For logs and metrics, visit CloudWatch dashboards (links above)

For infrastructure changes, modify Terraform files and run `terraform apply`

---

**Last Updated**: December 18, 2025
**Deployment Region**: ap-south-1 (Mumbai)
**Strapi Version**: 5.31.2
**Environment**: development
