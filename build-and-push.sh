#!/bin/bash

# Build and Push Strapi Docker Image to ECR
# This script builds the Docker image and pushes it to AWS ECR

region="ap-south-1"
accountId="301782007642"
repositoryName="irfan-strapi-image"
ecrUri="$accountId.dkr.ecr.$region.amazonaws.com/$repositoryName:latest"

echo "Building and pushing Docker image to ECR..."
echo "ECR URI: $ecrUri"
echo ""

# Step 1: Login to ECR
echo "Step 1: Logging in to AWS ECR..."
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin "$accountId.dkr.ecr.$region.amazonaws.com"

if [ $? -ne 0 ]; then
    echo "Failed to login to ECR. Make sure Docker is running and AWS credentials are configured."
    exit 1
fi

# Step 2: Build Docker image
echo ""
echo "Step 2: Building Docker image..."
docker build -t $ecrUri .

if [ $? -ne 0 ]; then
    echo "Failed to build Docker image."
    exit 1
fi

# Step 3: Push to ECR
echo ""
echo "Step 3: Pushing image to ECR..."
docker push $ecrUri

if [ $? -ne 0 ]; then
    echo "Failed to push image to ECR."
    exit 1
fi

echo ""
echo "✅ Success! Image pushed to ECR: $ecrUri"
echo ""
echo "You can now deploy to ECS with: terraform apply"
