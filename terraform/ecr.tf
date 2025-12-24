# =============================================================================
# Amazon ECR Repository for Strapi Application
# =============================================================================

resource "aws_ecr_repository" "strapi" {
  name                 = "strapi-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "strapi-ecr-repository"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# ECR Lifecycle Policy - Keep only last 10 images to save costs
resource "aws_ecr_lifecycle_policy" "strapi" {
  repository = aws_ecr_repository.strapi.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# =============================================================================
# Outputs
# =============================================================================

output "ecr_repository_url" {
  value       = aws_ecr_repository.strapi.repository_url
  description = "ECR Repository URL for Strapi application"
}

output "ecr_repository_arn" {
  value       = aws_ecr_repository.strapi.arn
  description = "ECR Repository ARN"
}

output "ecr_registry_id" {
  value       = aws_ecr_repository.strapi.registry_id
  description = "ECR Registry ID"
}
