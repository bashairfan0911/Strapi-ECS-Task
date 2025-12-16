# Terraform Module Organization Guide

## Directory Structure

```
terraform/
├── main.tf                 # Root module configuration
├── variables.tf            # Root variables definition
├── output.tf               # Root outputs
├── provider.tf             # Terraform provider configuration
├── terraform.tfvars        # Default/dev environment variables
├── environments/           # Environment-specific configurations
│   ├── prod.tfvars        # Production variables
│   └── staging.tfvars     # Staging variables
├── modules/               # Reusable Terraform modules
│   ├── vpc/               # VPC & Subnets module
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── security/          # Security Groups module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/               # RDS Database module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2/               # EC2 Instance module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── user_data.sh
├── .terraform.lock.hcl    # Dependency lock file
└── terraform.tfstate      # State file (git-ignored in production)
```

## Module Descriptions

### VPC Module (`modules/vpc/`)
Manages Virtual Private Cloud networking:
- Fetches default VPC data
- Retrieves available subnets
- Exports VPC and subnet information to other modules

### Security Module (`modules/security/`)
Manages AWS Security Groups:
- Strapi Security Group (allows SSH, HTTP, HTTPS, Strapi port)
- RDS Security Group (allows PostgreSQL from Strapi only)

### RDS Module (`modules/rds/`)
Manages PostgreSQL Database:
- Creates DB subnet group
- Provisions RDS PostgreSQL instance
- Configures networking and security

### EC2 Module (`modules/ec2/`)
Manages EC2 Instance:
- Launches Amazon Linux 2 instance
- Installs Docker and Docker credentials
- Pulls and runs Strapi container
- Configures environment variables

## Usage

### Initialize Terraform
```bash
cd terraform
terraform init
```

### Plan Deployment
```bash
# Development (uses terraform.tfvars)
terraform plan

# Production
terraform plan -var-file="environments/prod.tfvars"

# Staging
terraform plan -var-file="environments/staging.tfvars"
```

### Apply Configuration
```bash
# Development
terraform apply

# Production (with approval)
terraform apply -var-file="environments/prod.tfvars"
```

### Destroy Infrastructure
```bash
# Careful! This will delete all resources
terraform destroy

# Destroy specific environment
terraform destroy -var-file="environments/prod.tfvars"
```

## Important Notes

1. **Security**: 
   - Never commit `.tfvars` files with passwords to git
   - Use AWS Secrets Manager or environment variables for sensitive data
   - Review `.gitignore` to ensure state files are not tracked

2. **State Management**:
   - In production, use remote state (S3 + DynamoDB)
   - Never commit `terraform.tfstate` to version control
   - Use state locking to prevent concurrent modifications

3. **Environment Separation**:
   - Use separate `.tfvars` files for dev, staging, and production
   - Consider separate AWS accounts for production

4. **Module Reusability**:
   - Each module is self-contained and reusable
   - Modify inputs to customize behavior per environment
   - Add new modules for additional resources (ALB, Auto Scaling, etc.)

## Next Steps

1. Update database passwords in `.tfvars` files
2. Create EC2 Key Pair in AWS console
3. Set environment variables or use `.env` files
4. Run `terraform plan` to review changes
5. Run `terraform apply` to create infrastructure
6. Monitor outputs for access URLs and endpoints

