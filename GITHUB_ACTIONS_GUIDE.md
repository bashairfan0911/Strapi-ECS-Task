# 🚀 GitHub Actions CI/CD Guide for Strapi ECS

## Overview

This guide explains how GitHub Actions automates your Strapi deployment pipeline, from code push to live production deployment.

---

## 🔄 CI/CD Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  GitHub Repository                          │
│  (Push code changes → triggers automatic pipeline)          │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  CI Workflow: Build & Push to ECR                           │
│  1. Checkout code                                           │
│  2. Build Docker image                                      │
│  3. Push to AWS ECR                                         │
│  4. Notify deployment ready                                 │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  CD Workflow: Deploy via Terraform                          │
│  1. Verify Docker image in ECR                              │
│  2. Plan infrastructure changes                             │
│  3. Apply Terraform changes                                 │
│  4. Update ECS service with new image                       │
│  5. Health check and verification                           │
│  6. Post deployment summary                                 │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Live Production                                            │
│  Strapi running with new code/configuration                │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Prerequisites

### Required GitHub Secrets

Add these secrets to your GitHub repository:

**Settings → Secrets and variables → Actions**

```
AWS_ACCESS_KEY_ID       = Your AWS access key
AWS_SECRET_ACCESS_KEY   = Your AWS secret key
AWS_REGION              = ap-south-1
AWS_ACCOUNT_ID          = 301782007642
```

#### To get AWS credentials:

1. Go to AWS IAM Console
2. Create new IAM user (or use existing)
3. Attach policies:
   - `AmazonEC2ContainerRegistryPowerUser` (for ECR)
   - `AmazonECS_FullAccess` (for ECS)
   - `IAMFullAccess` (for IAM roles)
   - `AWSCloudFormationFullAccess` (for Terraform)

4. Generate access key
5. Add to GitHub Secrets

---

## 🔄 CI Workflow: `ci.yml`

**Triggers on:**
- Push to `main` branch with changes in:
  - `src/**` (application code)
  - `config/**` (configuration)
  - `Dockerfile` (container definition)
  - `package.json` (dependencies)
- Pull requests to `main` with same paths

**Steps:**

### 1. Checkout Code
```yaml
- Checkout repository
- Get latest code from GitHub
```

### 2. Set up Docker Buildx
```yaml
- Use BuildKit for faster builds
- Enable advanced Docker features
```

### 3. Configure AWS Credentials
```yaml
- Use secrets from GitHub Actions
- Authenticate with AWS
```

### 4. Login to ECR
```yaml
- Get temporary ECR credentials
- Enable Docker to push to ECR
```

### 5. Build Docker Image
```bash
docker build -t [ECR_URI]:sha1234 .
docker tag [ECR_URI]:sha1234 [ECR_URI]:latest
```

**Build args:**
- `NODE_ENV=production` - Production build

**Tags:**
- `latest` - Most recent image
- `sha1234` - Specific commit ID

### 6. Push to ECR
```bash
docker push [ECR_URI]:latest
docker push [ECR_URI]:sha1234
```

**Result:** Image available in ECR for deployment

### 7. Output Image URI
```
image-uri=301782007642.dkr.ecr.ap-south-1.amazonaws.com/irfan-strapi-image:latest
```

---

## 🚀 CD Workflow: `cd.yml`

**Triggers on:**

1. **CI Success:** Automatically after CI completes successfully
2. **Terraform Changes:** Push to `terraform/` directory
3. **Manual Trigger:** `workflow_dispatch` in GitHub UI

**Steps:**

### 1. Checkout Code
```yaml
- Get latest code including Terraform files
```

### 2. Configure AWS Credentials
```yaml
- Use same AWS credentials as CI
- Authenticate for Terraform operations
```

### 3. Determine Image Tag
```bash
# From workflow_run (CI)
IMAGE_TAG = CI's commit SHA

# From push/manual
IMAGE_TAG = Current commit SHA
```

### 4. Verify Image in ECR
```bash
aws ecr describe-images --repository-name irfan-strapi-image
```

Ensures image was successfully pushed before deploying.

### 5. Setup Terraform
```yaml
- Install Terraform v1.12.2
- Configure AWS provider
```

### 6. Terraform Validate
```bash
terraform fmt -check         # Check formatting
terraform validate           # Check syntax
```

### 7. Terraform Plan
```bash
terraform plan \
  -var="image_uri=301782007642.dkr.ecr.ap-south-1.amazonaws.com/irfan-strapi-image:latest" \
  -out=tfplan
```

Creates deployment plan without making changes.

**Review changes:**
```
+ aws_ecs_task_definition - New task version
~ aws_ecs_service - Service update with new image
```

### 8. Terraform Apply
```bash
terraform apply -auto-approve tfplan
```

Deploys infrastructure changes:
- Updates ECS task definition
- Updates ECS service
- Pulls new image
- Deploys new tasks

### 9. Wait for Stability
```bash
aws ecs wait services-stable \
  --cluster strapi-ecs-irfan-cluster \
  --services strapi-service
```

Waits for new tasks to start and become healthy.

### 10. Verify Service Health
```bash
# Get running vs desired count
aws ecs describe-services ...
```

Shows deployment status.

### 11. Get Application URL
```bash
# Retrieve new public IP
aws ecs list-tasks ... → task ARN
aws ecs describe-tasks ... → network interface
aws ec2 describe-network-interfaces ... → public IP
```

### 12. Post Deployment Summary
```
## 🚀 Deployment Summary
- Status: ✅ Success
- Image: 301782007642.dkr.ecr.ap-south-1.amazonaws.com/irfan-strapi-image:latest
- Cluster: strapi-ecs-irfan-cluster
- CloudWatch Dashboard: [link]
- Application: http://3.7.252.173:1337
```

---

## 📊 Monitoring Workflows

### View Workflow Runs

**GitHub:** Actions → CI/CD Workflows → Select workflow

**Details shown:**
- ✅/❌ Status (passed/failed)
- ⏱️ Duration
- 📝 Logs for each step
- 🔄 Triggers (push, PR, manual)

### Debugging Failed Workflows

1. **Click workflow run**
2. **Expand failed step**
3. **View error logs**

Common errors:
```
❌ "ECR repository not found"
   → Repository doesn't exist, create it manually

❌ "AWS credentials invalid"
   → Check GitHub Secrets are configured

❌ "Docker build failed"
   → Check Dockerfile syntax

❌ "Terraform validation failed"
   → Check .tf files for syntax errors
```

---

## 🔧 Manual Workflow Trigger

### Trigger CD Manually

1. **GitHub → Actions**
2. **CD - Deploy to ECS using Terraform**
3. **Run workflow**
4. **Select environment:**
   - production (default)
   - staging

### When to use manual trigger:
- Deploy without code changes (configuration only)
- Rollback to previous version
- Apply critical fixes
- Manual scaling

---

## 📈 Best Practices

### 1. Branch Protection Rules
**Enforce CI/CD before merge:**

Settings → Branches → Add rule
```
Branch name pattern: main
Require status checks to pass: ✓
  - Require builds to pass
  - Require CD approval
```

### 2. Pull Request Reviews
```
- Code review before merge
- Automated tests pass
- CD deployment approved
```

### 3. Commit Messages
```
Good commit messages:
✅ "feat: add article pagination"
✅ "fix: database connection timeout"
✅ "chore: update dependencies"

Bad:
❌ "update"
❌ "fix stuff"
❌ "test"
```

### 4. Test Before Push
```bash
# Validate locally before pushing
docker build .           # Build test
terraform validate       # Validate Terraform
```

### 5. Monitor Deployments
```
- Watch GitHub Actions for status
- Monitor CloudWatch logs post-deployment
- Check health metrics
- Verify application accessibility
```

---

## 🚨 Rollback Procedures

### If deployment goes wrong:

#### Option 1: Rollback via GitHub Actions
```
1. Go to Actions → CD Workflow
2. View past successful run
3. Re-run successful deployment
```

#### Option 2: Manual rollback via AWS
```bash
# Get previous ECS task definition revision
aws ecs list-task-definition-revisions \
  --family-prefix strapi-task \
  --region ap-south-1

# Update service to previous revision
aws ecs update-service \
  --cluster strapi-ecs-irfan-cluster \
  --service strapi-service \
  --task-definition strapi-task:1 \
  --region ap-south-1
```

---

## 📝 Environment Variables for CD

Available in CD workflow:

```yaml
env:
  AWS_REGION: ap-south-1
  AWS_ACCOUNT_ID: 301782007642
  ECR_REPOSITORY: irfan-strapi-image
  CLUSTER_NAME: strapi-ecs-irfan-cluster
  SERVICE_NAME: strapi-service
```

---

## 🔐 Security Best Practices

### 1. Secrets Management
```
✅ Store AWS credentials in GitHub Secrets
✅ Rotate credentials regularly
❌ Never commit credentials
❌ Don't expose secrets in logs
```

### 2. IAM Permissions
```
Principle of Least Privilege:
- Only grant needed permissions
- Use specific ARNs, not wildcards
- Review permissions quarterly
```

### 3. Code Review
```
- All changes require review
- Automated tests must pass
- Manual approval for production
```

### 4. Audit Logs
```bash
# View GitHub Actions audit log
GitHub → Settings → Audit log

# View AWS CloudTrail
AWS Console → CloudTrail → Event history
```

---

## 📊 Workflow Metrics

### Track deployment metrics:

```bash
# Number of deployments per day
# Average deployment time
# Success rate
# Rollback frequency
```

**Goal:** Improve velocity while maintaining stability

---

## 🎯 Optimization Tips

### Faster Builds

1. **Docker layer caching**
   - Cache dependencies layer
   - Minimize layer changes

2. **Parallel jobs**
   - Current: Sequential (build → deploy)
   - Future: Add parallel tests

3. **BuildKit**
   - Already enabled via `setup-buildx-action`

### Faster Deployments

1. **Blue-green deployment**
   - Run new and old in parallel
   - Switch traffic when ready
   - Instant rollback capability

2. **Rolling updates**
   - Update one task at a time
   - Zero downtime
   - Current approach

---

## 📚 Advanced Configurations

### Add automated tests before deployment:

```yaml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Run tests
      run: npm run test
    - name: Run lint
      run: npm run lint
```

### Add approval gates:

```yaml
deploy:
  environment:
    name: production
    # Require manual approval
  runs-on: ubuntu-latest
```

### Add notifications to Slack:

```yaml
- name: Slack notification
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "Deployment ${{ job.status }}"
      }
```

---

## ✅ Deployment Checklist

Before each deployment:

- [ ] Code changes reviewed and approved
- [ ] Dockerfile tested locally
- [ ] Terraform plan reviewed
- [ ] AWS credentials valid
- [ ] GitHub secrets configured
- [ ] CloudWatch monitoring active
- [ ] Rollback plan ready
- [ ] Team notified of deployment

---

## 📞 Support

### Common Issues & Solutions

**Issue:** Workflow stuck running
```
Solution: Click "Cancel workflow" → Re-run after fix
```

**Issue:** "Access Denied" from AWS
```
Solution: Check GitHub Secrets → Verify AWS credentials
```

**Issue:** Docker build timeout
```
Solution: Increase timeout → Optimize Dockerfile → Use cache
```

**Issue:** Terraform state lock
```
Solution: Delete lock file → terraform force-unlock ID
```

---

## 🔗 Related Documentation

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [CloudWatch Monitoring](./CLOUDWATCH_MONITORING.md)
- [How to Use Guide](./HOW_TO_USE.md)

---

**Status:** ✅ CI/CD pipeline fully automated

Last Updated: December 17, 2025
