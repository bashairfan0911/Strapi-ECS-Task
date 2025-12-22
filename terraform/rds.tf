resource "aws_db_subnet_group" "default" {
  name       = "strapi-db-subnet-group-irfan-ap"
  subnet_ids = data.aws_subnets.default_vpc_subnets.ids

  tags = {
    Name = "strapi-db-subnet-group-irfan"
  }
}

resource "aws_db_instance" "strapi_db" {
  identifier             = "strapidb-irfan-ap" // DB instance identifier
  allocated_storage      = 20
  engine                 = "postgres" // Using PostgreSQL
  engine_version         = "14"
  instance_class         = "db.t3.micro" // Free tier eligible
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  multi_az               = false // Single AZ for cost savings
  tags = {
    Name = "irfan-strapi-rds" // Tag for identification
  }
}
