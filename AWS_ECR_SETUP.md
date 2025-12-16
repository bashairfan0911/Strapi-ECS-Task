# AWS ECR + CI/CD Setup Guide

## Prerequisites
- AWS Account with appropriate permissions
- GitHub repository (this project)
- AWS CLI installed (optional, but helpful)

## Step 1: Create AWS ECR Repository

### Option A: Using AWS Console
1. Go to **AWS Console** → **ECR (Elastic Container Registry)**
2. Click **Create Repository**
3. Name: `irfan-strapi-image`
4. Keep other settings default
5. Click **Create Repository**
6. Note the URI (format: `ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/irfan-strapi-image`)

### Option B: Using AWS CLI
```bash
aws ecr create-repository --repository-name irfan-strapi-image --region eu-north-1
```

## Step 2: Create IAM User for GitHub Actions

1. Go to **AWS IAM** → **Users** → **Create User**
2. Username: `github-actions-user`
3. Skip "Add User to Groups" for now
4. **Create User**

## Step 3: Create Access Keys

1. Go to your new IAM user
2. Click **Security Credentials** tab
3. **Create Access Key**
4. Select **Third-party service**
5. Copy:
   - **Access Key ID**
   - **Secret Access Key**
6. Keep these safe!

## Step 4: Attach ECR Policy to IAM User

1. In IAM user details, click **Add Permissions** → **Attach Policies Directly**
2. Search for and select: `AmazonEC2ContainerRegistryPowerUser`
3. Click **Add Permissions**

## Step 5: Configure GitHub Secrets

1. Go to your GitHub repository
2. **Settings** → **Secrets and Variables** → **Actions**
3. Click **New Repository Secret** and add:

   | Secret Name | Value |
   |-------------|-------|
   | `AWS_ACCESS_KEY_ID` | Your Access Key ID from Step 3 |
   | `AWS_SECRET_ACCESS_KEY` | Your Secret Access Key from Step 3 |
   | `AWS_REGION` | `eu-north-1` (or your preferred region) |

## Step 6: Verify the Workflow

The workflow file (`.github/workflows/ci.yml`) is already configured. It will:
- Trigger on every push to `main` branch
- Build the Docker image
- Push it to ECR with:
  - Tag: `ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com/irfan-strapi-image:COMMIT_SHA`
  - Latest tag: `ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com/irfan-strapi-image:latest`

## Step 7: Test the Workflow

1. Make a change to `src/` or `Dockerfile`
2. Push to `main` branch:
   ```bash
   git add .
   git commit -m "Test CI/CD workflow"
   git push origin main
   ```
3. Go to **GitHub** → **Actions** tab
4. Watch the workflow run
5. Check ECR repository for the pushed image

## Step 8: Deploy from ECR (Optional)

To deploy this image to AWS infrastructure:

### Using ECS (Elastic Container Service)
1. Create an ECS cluster
2. Create a task definition using the ECR image URI
3. Create an ECS service
4. Configure load balancer and security groups

### Using EC2 with Docker
1. Launch an EC2 instance
2. Install Docker
3. Authenticate with ECR: `aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com`
4. Pull and run: `docker run -d -p 80:80 -p 1337:1337 ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com/irfan-strapi-image:latest`

### Using Terraform (Already in project!)
The project includes Terraform files to provision:
- VPC with subnets
- RDS PostgreSQL database
- EC2 instance
- Security groups
- Nginx reverse proxy

See `terraform/` folder for configuration.

## Troubleshooting

### Workflow fails with "Access Denied"
- Verify AWS credentials are correct in GitHub Secrets
- Check IAM user has `AmazonEC2ContainerRegistryPowerUser` policy

### Image doesn't appear in ECR
- Check GitHub Actions logs for build errors
- Verify repository name matches: `irfan-strapi-image`
- Confirm AWS_REGION is correct

### Authentication Error
- Regenerate Access Keys if lost
- Update GitHub Secrets with new credentials

## Security Best Practices

1. **Rotate Access Keys** regularly
2. **Use IAM Roles** instead of Access Keys when possible
3. **Limit Policy Scope** - Consider custom policies instead of PowerUser
4. **Enable ECR Lifecycle Policies** to clean up old images
5. **Use Private ECR Repository** (default setting)
6. **Enable Image Scanning** for vulnerability detection

