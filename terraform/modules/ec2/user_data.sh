#!/bin/bash
set -xe

# Update system packages
yum update -y

# Install Docker and AWS CLI
yum install -y docker awscli

# Start Docker service
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Login to ECR
aws ecr get-login-password --region ${aws_region} \
  | docker login --username AWS --password-stdin ${ecr_registry}

# Pull Docker image
docker pull ${docker_image}

# Remove existing container if running
docker rm -f strapi || true

# Run Strapi container
docker run -d --name strapi -p 1337:1337 \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST="${db_host}" \
  -e DATABASE_PORT=5432 \
  -e DATABASE_NAME="${db_name}" \
  -e DATABASE_USERNAME="${db_username}" \
  -e DATABASE_PASSWORD="${db_password}" \
  ${docker_image}

echo "Strapi container started successfully"
