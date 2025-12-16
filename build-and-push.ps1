# Build and Push Strapi Docker Image to ECR
# This script builds the Docker image and pushes it to AWS ECR

$region = "ap-south-1"
$accountId = "301782007642"
$repositoryName = "irfan-strapi-image"
$ecrUri = "$accountId.dkr.ecr.$region.amazonaws.com/$repositoryName:latest"

Write-Host "Building and pushing Docker image to ECR..."
Write-Host "ECR URI: $ecrUri"
Write-Host ""

# Step 1: Login to ECR
Write-Host "Step 1: Logging in to AWS ECR..."
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin "$accountId.dkr.ecr.$region.amazonaws.com"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to login to ECR. Make sure Docker is running and AWS credentials are configured."
    exit 1
}

# Step 2: Build Docker image
Write-Host ""
Write-Host "Step 2: Building Docker image..."
docker build -t $ecrUri .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to build Docker image."
    exit 1
}

# Step 3: Push to ECR
Write-Host ""
Write-Host "Step 3: Pushing image to ECR..."
docker push $ecrUri

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to push image to ECR."
    exit 1
}

Write-Host ""
Write-Host "✅ Success! Image pushed to ECR: $ecrUri"
Write-Host ""
Write-Host "You can now deploy to ECS with: terraform apply"
