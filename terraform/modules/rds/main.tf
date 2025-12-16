resource "aws_db_subnet_group" "strapi" {
  name       = "strapi-db-subnet-group-irfan"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "irfan-strapi-db-subnet-group"
  }
}

resource "aws_db_instance" "strapi_db" {
  identifier           = "strapidb-irfan"
  allocated_storage   = var.allocated_storage
  engine              = var.engine
  engine_version      = var.engine_version
  instance_class      = var.instance_class
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = var.skip_final_snapshot
  publicly_accessible = var.publicly_accessible

  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.strapi.name

  multi_az = var.multi_az

  tags = {
    Name = "irfan-strapi-rds"
  }
}
