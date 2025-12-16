data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "strapi_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  user_data = templatefile("${path.module}/user_data.sh", {
    docker_image  = var.docker_image
    aws_region    = var.aws_region
    ecr_registry  = var.ecr_registry
    db_host       = var.db_host
    db_name       = var.db_name
    db_username   = var.db_username
    db_password   = var.db_password
  })

  tags = {
    Name = "irfan-strapi-ec2"
  }
}
