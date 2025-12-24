# =============================================================================
# VPC and Subnet Data Sources
# =============================================================================

data "aws_vpc" "default" {
  default = true
}

# Get all subnets in the VPC
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Get subnet details to filter one subnet per AZ
data "aws_subnet" "selected" {
  for_each = toset(data.aws_subnets.default_vpc_subnets.ids)
  id       = each.value
}

# Create a map of AZ to subnet (one subnet per AZ for ALB)
locals {
  # Get unique subnets - one per availability zone
  az_subnet_map = {
    for s in data.aws_subnet.selected : s.availability_zone => s.id...
  }
  # Select first subnet from each AZ (ALB needs min 2 AZs)
  unique_az_subnets = [for az, subnets in local.az_subnet_map : subnets[0]]
  
  # All available subnets for ECS and RDS
  all_subnets = [for s in data.aws_subnet.selected : s.id]
}
