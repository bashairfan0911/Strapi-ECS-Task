# Strapi ECS Blue/Green Deployment

A production-ready Strapi CMS application deployed on AWS ECS with Blue/Green deployment strategy using AWS CodeDeploy.

## Architecture Overview

This project implements a zero-downtime Blue/Green deployment architecture for a Strapi application on AWS ECS Fargate.

### Key Components

- **ECS Cluster**: `strapi-ecs-irfan-cluster` with Container Insights enabled
- **ECS Service**: Fargate-based service with CODE_DEPLOY deployment controller
- **Application Load Balancer (ALB)**: Routes traffic between Blue and Green target groups
- **CodeDeploy**: Manages automated Blue/Green deployments with canary strategy
- **RDS PostgreSQL**: Database backend for Strapi
- **CloudWatch**: Comprehensive monitoring and logging

## Infrastructure Components

### 1. ECS Cluster and Service

- **Launch Type**: AWS Fargate (serverless)
- **Service Name**: `strapi-service`
- **Desired Tasks**: 2
- **Platform Version**: 1.4.0
- **Deployment Controller**: CODE_DEPLOY (enables Blue/Green deployments)

### 2. Application Load Balancer (ALB)

**Security Configuration**:
- HTTP (Port 80): Production traffic
- HTTPS (Port 443): Secure production traffic
- Port 8080: Test listener for validating Green environment

**Target Groups**:
- **Blue Target Group**: `strapi-tg-blue-irfan` - Current production
- **Green Target Group**: `strapi-tg-green-irfan` - New deployment staging

**Health Checks**:
- Path: `/`
- Healthy threshold: 2 consecutive successes
- Unhealthy threshold: 3 consecutive failures
- Interval: 30 seconds
- Timeout: 5 seconds
- Success codes: 200-399

### 3. ECS Task Definition

**Task Configuration**:
- CPU: 512 (0.5 vCPU)
- Memory: 1024 MB
- Container Port: 1337 (Strapi default)
- Network Mode: awsvpc

**Dynamic Updates**: Task definitions are updated outside of Terraform and deployed via CodeDeploy to enable true Blue/Green deployments.

### 4. AWS CodeDeploy Configuration

**Application**: `strapi-ecs-app-irfan`

**Deployment Group**: `strapi-deployment-group-irfan`

**Deployment Strategy**: `CodeDeployDefault.ECSCanary10Percent5Minutes`
- Initial: 10% traffic to Green environment
- Wait: 5 minutes for validation
- Final: 100% traffic to Green environment

**Automatic Rollback**: Enabled on:
- Deployment failure
- Deployment stop on request

**Blue Instance Termination**: 5 minutes after successful deployment

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Docker (for local builds)
- Node.js >= 18 (for Strapi development)

## Setup Instructions

### 1. Configure AWS Credentials

```bash
aws configure
```

### 2. Update Terraform Variables

Edit `terraform/terraform.tfvars`:

```hcl
aws_region      = "ap-south-1"
project_name    = "strapi-ecs"
environment     = "production"
db_username     = "your-db-username"
db_password     = "your-secure-password"
```

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

### 4. Deploy Infrastructure

```bash
terraform plan
terraform apply
```

This creates:
- ECS Cluster with Container Insights
- ALB with Blue/Green target groups
- ECS Service with CODE_DEPLOY controller
- CodeDeploy Application and Deployment Group
- RDS PostgreSQL database
- CloudWatch dashboards and alarms
- Security groups and IAM roles

## Deployment Process

### Initial Deployment

After Terraform creates the infrastructure, deploy your first task:

```bash
# 1. Update task definition with new Docker image
terraform apply -target=aws_ecs_task_definition.this

# 2. Create deployment via CodeDeploy
aws deploy create-deployment \
  --application-name strapi-ecs-app-irfan \
  --deployment-group-name strapi-deployment-group-irfan \
  --revision "{\"revisionType\":\"AppSpecContent\",\"appSpecContent\":{\"content\":\"{\\\"version\\\":0.0,\\\"Resources\\\":[{\\\"TargetService\\\":{\\\"Type\\\":\\\"AWS::ECS::Service\\\",\\\"Properties\\\":{\\\"TaskDefinition\\\":\\\"arn:aws:ecs:ap-south-1:ACCOUNT_ID:task-definition/strapi-task:REVISION\\\",\\\"LoadBalancerInfo\\\":{\\\"ContainerName\\\":\\\"strapi\\\",\\\"ContainerPort\\\":1337}}}}]}\"}}"
```

### Subsequent Deployments

1. **Update Application Code**
   ```bash
   # Build and push new Docker image
   docker build -t strapi:latest .
   docker tag strapi:latest ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/strapi:latest
   docker push ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/strapi:latest
   ```

2. **Update Task Definition**
   ```bash
   terraform apply -target=aws_ecs_task_definition.this
   ```

3. **Trigger Blue/Green Deployment**
   - CodeDeploy automatically deploys to Green target group
   - New tasks start and undergo health checks
   - Test listener (port 8080) allows validation
   - Traffic shifts: 10% → wait 5 min → 100%
   - Old Blue tasks terminate after 5 minutes

### Traffic Flow During Deployment

**Before Deployment:**
```
Port 80 → Blue Target Group → Old Tasks (v1)
Port 8080 → Green Target Group → (empty)
```

**During Deployment:**
```
Port 80 → Blue (90%) + Green (10%) → Mixed traffic
Port 8080 → Green Target Group → New Tasks (v2) [Testing]
```

**After Deployment:**
```
Port 80 → Green Target Group → New Tasks (v2)
Port 8080 → Blue Target Group → (ready for next deployment)
```

## Monitoring

### CloudWatch Dashboards

1. **strapi-application-monitoring**
   - ECS CPU and Memory utilization
   - RDS database metrics
   - ALB traffic and response codes
   - Task deployment status

2. **strapi-performance-monitoring**
   - CPU/Memory trends (Peak, Min, Avg)
   - Application response times (Blue/Green)
   - RDS network throughput
   - Request count

### CloudWatch Alarms

- `strapi-ecs-cpu-utilization-high` - CPU > 80%
- `strapi-ecs-memory-utilization-high` - Memory > 85%
- `strapi-ecs-running-task-count-low` - Running tasks < 1
- `strapi-rds-cpu-utilization-high` - RDS CPU > 75%
- `strapi-rds-database-connections-high` - Connections > 80

### Access Logs

```bash
# ECS Container Logs
aws logs tail /ecs/strapi --follow

# Get specific task logs
aws logs get-log-events \
  --log-group-name /ecs/strapi \
  --log-stream-name ecs/strapi/CONTAINER_ID
```

## Access URLs

- **Production**: http://strapi-alb-irfan-1870158425.ap-south-1.elb.amazonaws.com
- **Test/Validation**: http://strapi-alb-irfan-1870158425.ap-south-1.elb.amazonaws.com:8080
- **CloudWatch Dashboard**: https://console.aws.amazon.com/cloudwatch/home?region=ap-south-1#dashboards:name=strapi-application-monitoring

## Security Groups

### ALB Security Group
- **Inbound**: Ports 80, 443, 8080 from 0.0.0.0/0
- **Outbound**: All traffic

### ECS Security Group
- **Inbound**: Port 1337 from ALB security group only
- **Outbound**: All traffic

### RDS Security Group
- **Inbound**: Port 5432 from ECS security group only
- **Outbound**: None

## Environment Variables

Key environment variables configured in the ECS task definition:

- `NODE_ENV=production`
- `DATABASE_CLIENT=postgres`
- `DATABASE_HOST` - RDS endpoint
- `DATABASE_PORT=5432`
- `DATABASE_NAME=strapidb`
- `JWT_SECRET` - Authentication secret
- `ADMIN_JWT_SECRET` - Admin panel authentication
- `APP_KEYS` - Application encryption keys

## Troubleshooting

### 502 Bad Gateway

Check ECS task logs for application errors:
```bash
aws ecs describe-services \
  --cluster strapi-ecs-irfan-cluster \
  --services strapi-service

aws logs tail /ecs/strapi --follow
```

### Deployment Failed

1. Check CodeDeploy deployment status:
   ```bash
   aws deploy get-deployment --deployment-id DEPLOYMENT_ID
   ```

2. Review CloudWatch alarms for threshold breaches

3. Validate task definition configuration

### No Healthy Targets

1. Check target group health:
   ```bash
   aws elbv2 describe-target-health \
     --target-group-arn TARGET_GROUP_ARN
   ```

2. Verify security group rules allow ALB → ECS traffic

3. Confirm application is listening on port 1337

## Infrastructure Outputs

After deployment, Terraform provides:

- `alb_dns_name` - Load balancer endpoint
- `ecs_cluster_name` - ECS cluster name
- `ecs_service_name` - ECS service name
- `codedeploy_app_name` - CodeDeploy application
- `rds_endpoint` - Database endpoint
- `cloudwatch_dashboard_url` - Monitoring dashboard

## Cost Optimization

- **Fargate Tasks**: Pay only for vCPU and memory used
- **RDS**: Consider Reserved Instances for production
- **ALB**: Single ALB for both Blue/Green deployments
- **CloudWatch Logs**: 7-day retention configured

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

**Warning**: This will permanently delete all data including the RDS database.

## License

MIT

## Support

For issues or questions, refer to:
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS CodeDeploy Documentation](https://docs.aws.amazon.com/codedeploy/)
- [Strapi Documentation](https://docs.strapi.io/)
