# 🚀 Strapi CMS on AWS ECS - Complete Usage Guide

**Live Application:** http://3.7.252.173:1337

## 📖 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Getting Started](#getting-started)
5. [Accessing the Application](#accessing-the-application)
6. [Managing Content](#managing-content)
7. [API Endpoints](#api-endpoints)
8. [Database Connection](#database-connection)
9. [Docker & Deployment](#docker--deployment)
10. [Terraform Infrastructure](#terraform-infrastructure)
11. [Troubleshooting](#troubleshooting)
12. [Development](#development)
13. [Production Deployment](#production-deployment)
14. [FAQ](#faq)

---

## 📋 Project Overview

This project deploys **Strapi**, a modern headless CMS, to **AWS ECS (Elastic Container Service)** using Docker containers and Infrastructure as Code (Terraform).

### Key Features:
- ✅ Headless CMS for content management
- ✅ RESTful API for accessing content
- ✅ Containerized with Docker
- ✅ Deployed on AWS ECS Fargate (serverless)
- ✅ PostgreSQL 14 database for data persistence
- ✅ Infrastructure as Code with Terraform
- ✅ Pre-built content types (Articles, Todos)
- ✅ Scalable and cost-efficient

### What is Strapi?
Strapi is a **headless CMS** that:
- Provides a user-friendly admin panel for content management
- Exposes content via REST API
- Allows you to define custom content types (Collections)
- Separates content from presentation (headless)
- Can serve multiple frontends (web, mobile, etc.)

---

## 🏗️ Architecture

### Cloud Infrastructure
```
┌────────────────────────────────────────────────────┐
│          AWS Region: ap-south-1 (Mumbai)           │
├────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │         ECS Cluster (Fargate)                │  │
│  │  ┌────────────────────────────────────────┐  │  │
│  │  │  ECS Service: strapi-service           │  │  │
│  │  │  ┌──────────────────────────────────┐  │  │  │
│  │  │  │  Docker Container                │  │  │  │
│  │  │  │  - Strapi Application            │  │  │  │
│  │  │  │  - Node 18-Alpine                │  │  │  │
│  │  │  │  - Port: 1337                    │  │  │  │
│  │  │  │  - Public IP: 3.7.252.173        │  │  │  │
│  │  │  └──────────────────────────────────┘  │  │  │
│  │  └────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │    RDS PostgreSQL Database                   │  │
│  │  - Instance: strapidb-irfan-ap               │  │
│  │  - Engine: PostgreSQL 14                     │  │
│  │  - Database: strapidb                        │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │    ECR Repository                            │  │
│  │  - irfan-strapi-image:latest                │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
└────────────────────────────────────────────────────┘
```

### Technology Stack

| Component | Technology |
|-----------|-----------|
| Application | Strapi CMS |
| Container Runtime | Docker (Node 18-Alpine) |
| Orchestration | AWS ECS Fargate |
| Database | PostgreSQL 14 (RDS) |
| Container Registry | AWS ECR |
| Infrastructure | Terraform |
| Region | ap-south-1 (Mumbai) |
| Network | VPC with Security Groups |

---

## 📋 Prerequisites

### To Access the Live Application:
- Internet connection
- Web browser (Chrome, Firefox, Safari, Edge)
- No installation required!

### To Deploy or Modify:
- AWS Account (with appropriate credentials)
- Terraform installed (v1.12.2+)
- Docker Desktop installed
- AWS CLI configured
- Git (for version control)

---

## 🎯 Getting Started

### Option 1: Access Live Application (Easiest)

Simply open your browser and navigate to:
```
http://3.7.252.173:1337
```

### Option 2: Local Development

#### 1. Clone the Repository
```bash
git clone https://github.com/bashairfan0911/Strapi-ECS-Task.git
cd Strapi-ECS-Task
```

#### 2. Install Dependencies
```bash
npm install
```

#### 3. Configure Environment Variables
```bash
cp .env.example .env
```

Edit `.env` with your database credentials:
```env
DATABASE_CLIENT=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=strapidb
DATABASE_USERNAME=strapiuser
DATABASE_PASSWORD=your_password
ADMIN_JWT_SECRET=your-secret-key
APP_KEYS=key1,key2,key3
API_TOKEN_SALT=your-salt
TRANSFER_TOKEN_SALT=your-salt
ENCRYPTION_KEY=your-encryption-key
```

#### 4. Run Locally
```bash
npm run develop
```

The application will be available at: `http://localhost:1337`

---

## 🌐 Accessing the Application

### Live URL
```
http://3.7.252.173:1337
```

### What You'll See

**First Time Setup:**
1. You'll be redirected to the admin panel registration page
2. Create an admin account
3. Set up your Strapi instance

**Admin Panel:**
- Access content management interface
- Create, edit, delete content
- Manage roles and permissions
- Configure plugins and settings

### Admin Panel Features

#### Content Manager
- **Collections:** Articles, Todos (pre-built)
- **Create:** Add new content entries
- **Edit:** Modify existing content
- **Delete:** Remove content
- **Publish:** Make content live

#### Settings
- **Users:** Manage admin users
- **Roles:** Define role-based access control
- **API Tokens:** Create tokens for API access
- **Webhooks:** Configure webhooks for events

#### Plugins
- **Media Library:** Manage uploaded files
- **Content Type Builder:** Create custom content types
- **Marketplace:** Install additional plugins

---

## 📝 Managing Content

### Creating an Article

1. Go to **Content Manager** > **Articles**
2. Click **Create new entry**
3. Fill in the fields:
   - **Title:** Article name
   - **Content:** Article body
   - **Slug:** URL-friendly identifier
4. Click **Save**
5. Click **Publish** to make it live

### Creating a Todo

1. Go to **Content Manager** > **Todos**
2. Click **Create new entry**
3. Fill in the fields:
   - **Title:** Todo task name
   - **Completed:** Toggle completion status
4. Click **Save** > **Publish**

### Publishing vs Drafting

- **Draft:** Content saved but not visible via API
- **Published:** Content accessible to API consumers

---

## 🔌 API Endpoints

### Get All Articles
```bash
curl http://3.7.252.173:1337/api/articles
```

Response:
```json
{
  "data": [
    {
      "id": 1,
      "attributes": {
        "title": "My First Article",
        "content": "Article content here...",
        "slug": "my-first-article",
        "createdAt": "2025-12-16T10:30:00Z",
        "updatedAt": "2025-12-16T10:30:00Z"
      }
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "pageSize": 25,
      "pageCount": 1,
      "total": 1
    }
  }
}
```

### Get Single Article
```bash
curl http://3.7.252.173:1337/api/articles/1
```

### Get All Todos
```bash
curl http://3.7.252.173:1337/api/todos
```

### Create Article (with Authentication)
```bash
curl -X POST http://3.7.252.173:1337/api/articles \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "data": {
      "title": "New Article",
      "content": "Content here",
      "slug": "new-article"
    }
  }'
```

### Update Article
```bash
curl -X PUT http://3.7.252.173:1337/api/articles/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "data": {
      "title": "Updated Title"
    }
  }'
```

### Delete Article
```bash
curl -X DELETE http://3.7.252.173:1337/api/articles/1 \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

### Query Parameters

#### Populate Relations
```bash
curl http://3.7.252.173:1337/api/articles?populate=*
```

#### Filtering
```bash
curl http://3.7.252.173:1337/api/articles?filters[title][$contains]=Strapi
```

#### Sorting
```bash
curl http://3.7.252.173:1337/api/articles?sort=createdAt:desc
```

#### Pagination
```bash
curl http://3.7.252.173:1337/api/articles?pagination[page]=1&pagination[pageSize]=10
```

---

## 🗄️ Database Connection

### PostgreSQL Details

| Property | Value |
|----------|-------|
| **Engine** | PostgreSQL 14 |
| **Instance** | strapidb-irfan-ap |
| **Endpoint** | strapidb-irfan-ap.cbowmc0uim96.ap-south-1.rds.amazonaws.com |
| **Port** | 5432 |
| **Database** | strapidb |
| **Username** | strapiuser |
| **Password** | irfan123 (change in production!) |

### Connection String
```
postgres://strapiuser:irfan123@strapidb-irfan-ap.cbowmc0uim96.ap-south-1.rds.amazonaws.com:5432/strapidb
```

### Connecting via Local Tools

#### Using psql (PostgreSQL CLI)
```bash
psql -h strapidb-irfan-ap.cbowmc0uim96.ap-south-1.rds.amazonaws.com \
     -U strapiuser \
     -d strapidb \
     -p 5432
```

Then enter password: `irfan123`

#### Using DBeaver
1. Create new database connection
2. Select PostgreSQL
3. Fill in connection details above
4. Test connection
5. Connect

---

## 🐳 Docker & Deployment

### Building Docker Image Locally

```bash
# Navigate to project root
cd d:\STRAPI_ECS

# Build image
docker build -t strapi-image:latest .

# Run locally
docker run -p 1337:1337 \
  -e DATABASE_HOST=localhost \
  -e DATABASE_PORT=5432 \
  -e DATABASE_NAME=strapidb \
  -e DATABASE_USERNAME=strapiuser \
  -e DATABASE_PASSWORD=irfan123 \
  strapi-image:latest
```

### Pushing to AWS ECR

```bash
# Login to ECR
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS --password-stdin 301782007642.dkr.ecr.ap-south-1.amazonaws.com

# Tag image
docker tag strapi-image:latest \
  301782007642.dkr.ecr.ap-south-1.amazonaws.com/irfan-strapi-image:latest

# Push to ECR
docker push 301782007642.dkr.ecr.ap-south-1.amazonaws.com/irfan-strapi-image:latest

# ECS service automatically pulls and deploys new image
```

### Dockerfile Breakdown

```dockerfile
# Base image: Node 18 on Alpine Linux (lightweight)
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Install PostgreSQL driver
RUN npm install pg --save

# Copy application code
COPY . .

# Build Strapi
RUN npm run build

# Expose port
EXPOSE 1337

# Start application
CMD ["npm", "run", "start"]
```

---

## 🏢 Terraform Infrastructure

### Key Infrastructure Files

#### `terraform.tfvars` - Configuration
```hcl
aws_region    = "ap-south-1"
image_uri     = "301782007642.dkr.ecr.ap-south-1.amazonaws.com/irfan-strapi-image:latest"
db_name       = "strapidb"
db_username   = "strapiuser"
db_password   = "irfan123"
```

#### `ecs-cluster.tf` - ECS Cluster
Defines the ECS cluster where containers run.

#### `ecs-task.tf` - Task Definition
Specifies container configuration, environment variables, and resource allocation.

#### `ecs-service.tf` - ECS Service
Manages the service, scaling, and task deployment.

#### `rds.tf` - Database
Creates and configures PostgreSQL RDS instance.

#### `security.tf` - Security Groups
Defines network access rules.

#### `iam.tf` - IAM Roles
Sets up permissions for ECS tasks to access AWS services.

### Deploying Infrastructure

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply -auto-approve

# View outputs
terraform output
```

### Destroying Infrastructure (Cleanup)

⚠️ **Warning:** This will delete all AWS resources!

```bash
terraform destroy -auto-approve
```

---

## 🔧 Troubleshooting

### Issue: Cannot Access http://3.7.252.173:1337

**Solution:**
1. Verify ECS task is running:
   ```bash
   aws ecs describe-services \
     --cluster strapi-ecs-irfan-cluster \
     --services strapi-service \
     --region ap-south-1
   ```

2. Check task logs:
   ```bash
   aws logs tail /ecs/strapi-task --follow --region ap-south-1
   ```

3. Verify security group allows inbound traffic on port 1337:
   ```bash
   aws ec2 describe-security-groups \
     --group-ids sg-0defcd262a63b3e85 \
     --region ap-south-1
   ```

### Issue: Database Connection Error

**Solution:**
1. Verify RDS instance is running:
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier strapidb-irfan-ap \
     --region ap-south-1
   ```

2. Check RDS security group allows port 5432:
   ```bash
   aws ec2 describe-security-groups \
     --region ap-south-1 | grep -i rds
   ```

3. Verify database credentials in environment variables

### Issue: Container Fails to Start

**Solution:**
1. Check CloudWatch logs:
   ```bash
   aws logs tail /ecs/strapi-task --follow --region ap-south-1
   ```

2. Verify ECR image exists:
   ```bash
   aws ecr describe-images \
     --repository-name irfan-strapi-image \
     --region ap-south-1
   ```

3. Check task definition:
   ```bash
   aws ecs describe-task-definition \
     --task-definition strapi-task \
     --region ap-south-1
   ```

### Issue: Out of Memory

**Solution:**
Increase task memory in `ecs-task.tf`:
```hcl
memory = 2048  # Increase from 1024
```

Then redeploy:
```bash
terraform apply -auto-approve
```

---

## 💻 Development

### Project Structure

```
STRAPI_ECS/
├── src/
│   ├── api/
│   │   ├── article/           # Article content type
│   │   │   ├── controllers/
│   │   │   ├── routes/
│   │   │   ├── services/
│   │   │   └── content-types/
│   │   └── todo/              # Todo content type
│   ├── admin/                 # Admin panel customization
│   └── extensions/            # Custom plugins
├── config/
│   ├── admin.js               # Admin panel settings
│   ├── api.js                 # API configuration
│   ├── database.js            # Database config
│   ├── middlewares.js         # Middleware setup
│   ├── plugins.js             # Plugin configuration
│   └── server.js              # Server settings
├── terraform/                 # Infrastructure as Code
│   ├── ecs-cluster.tf
│   ├── ecs-task.tf
│   ├── ecs-service.tf
│   ├── rds.tf
│   ├── security.tf
│   ├── iam.tf
│   ├── provider.tf
│   ├── variable.tf
│   └── terraform.tfvars
├── Dockerfile                 # Container definition
├── package.json              # Node.js dependencies
└── README.md                 # This file
```

### Modifying Content Types

To add a new content type (e.g., "Blog Posts"):

1. Go to **Admin Panel** > **Content Type Builder**
2. Click **Create new collection type**
3. Name it "Blog Post"
4. Add fields (Title, Content, Author, etc.)
5. Configure permissions
6. Click **Save**

The API endpoint becomes: `http://3.7.252.173:1337/api/blog-posts`

### Adding Custom Fields to Existing Types

1. Go to **Content Type Builder**
2. Click on the collection (e.g., Articles)
3. Click **Add another field**
4. Select field type (Text, Image, Date, etc.)
5. Configure field settings
6. Click **Save**

---

## 🚀 Production Deployment

### Pre-Production Checklist

- [ ] Change database password to a strong value
- [ ] Update Strapi JWT secrets in `terraform.tfvars`
- [ ] Enable HTTPS/SSL certificate
- [ ] Configure CDN (CloudFront)
- [ ] Set up CloudWatch alarms
- [ ] Enable RDS automated backups
- [ ] Configure database encryption
- [ ] Set up WAF (Web Application Firewall)
- [ ] Enable CloudWatch logging
- [ ] Test disaster recovery

### Updating Credentials

1. Update `terraform.tfvars`:
   ```hcl
   db_password = "YOUR_STRONG_PASSWORD"
   ```

2. Update ECS task environment:
   ```bash
   terraform apply -auto-approve
   ```

3. Restart the service:
   ```bash
   aws ecs update-service \
     --cluster strapi-ecs-irfan-cluster \
     --service strapi-service \
     --force-new-deployment \
     --region ap-south-1
   ```

### Scaling the Service

To handle more traffic, increase task count:

1. Edit `terraform/ecs-service.tf`:
   ```hcl
   desired_count = 3  # Increase from 1
   ```

2. Apply changes:
   ```bash
   terraform apply -auto-approve
   ```

---

## ❓ FAQ

### Q: How do I backup my database?
**A:** AWS RDS automatically backs up to 7 days retention. For manual backup:
```bash
aws rds create-db-snapshot \
  --db-instance-identifier strapidb-irfan-ap \
  --db-snapshot-identifier backup-$(date +%s) \
  --region ap-south-1
```

### Q: How do I add SSL/TLS certificate?
**A:** 
1. Create certificate in AWS Certificate Manager
2. Attach to Application Load Balancer
3. Update Terraform configuration
4. Redeploy

### Q: How much does this cost?
**A:** 
- ECS Fargate: ~$15-30/month
- RDS db.t3.micro: Free tier (1st 12 months)
- ECR: ~$0.10/GB stored
- **Total:** ~$20-35/month

### Q: Can I use a different database?
**A:** Yes! Strapi supports MySQL, SQLite, MongoDB. Update `config/database.js` and `terraform/rds.tf`.

### Q: How do I restore from backup?
**A:**
```bash
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier strapidb-restored \
  --db-snapshot-identifier backup-id \
  --region ap-south-1
```

### Q: How do I monitor the application?
**A:** Use CloudWatch:
```bash
aws logs tail /ecs/strapi-task --follow --region ap-south-1
```

### Q: How do I add custom plugins?
**A:**
```bash
npm install @strapi/plugin-name --save
npm run build
docker build -t strapi-image:latest .
docker push ... (to ECR)
```

### Q: Can I use environment variables for secrets?
**A:** Yes! Update `ecs-task.tf`:
```hcl
environment = [
  { name = "API_KEY", value = var.api_key }
]
```

Then in `terraform.tfvars`:
```hcl
api_key = "your-secret-key"
```

### Q: How do I enable CORS?
**A:** Update `config/middlewares.js`:
```javascript
module.exports = [
  'strapi::cors',
  // ... other middleware
];
```

---

## 📞 Support & Resources

### Documentation
- **Strapi Docs:** https://docs.strapi.io
- **AWS ECS:** https://docs.aws.amazon.com/ecs/
- **Terraform:** https://www.terraform.io/docs/
- **PostgreSQL:** https://www.postgresql.org/docs/

### GitHub Repository
- **Project:** https://github.com/bashairfan0911/Strapi-ECS-Task.git
- **Issues:** Report bugs and request features

### Live Application
- **URL:** http://3.7.252.173:1337
- **Region:** ap-south-1 (AWS Mumbai)
- **Status:** Live and Running ✅

---

## 📜 License

This project is open source and available under the MIT License.

---

## 🎉 Getting Help

If you encounter issues:

1. **Check logs:**
   ```bash
   aws logs tail /ecs/strapi-task --follow --region ap-south-1
   ```

2. **Verify deployment:**
   ```bash
   aws ecs describe-services \
     --cluster strapi-ecs-irfan-cluster \
     --services strapi-service \
     --region ap-south-1
   ```

3. **Review documentation:** Check Strapi docs for CMS-specific issues

4. **Open GitHub issue:** Report bugs at the repository

---

**Last Updated:** December 16, 2025  
**Status:** ✅ Live and Running  
**Application:** http://3.7.252.173:1337
