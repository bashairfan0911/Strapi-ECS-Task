variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for DB subnet group"
}

variable "rds_security_group_id" {
  type        = string
  description = "Security group ID for RDS instance"
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage in GB"
}

variable "engine" {
  type        = string
  default     = "postgres"
  description = "Database engine"
}

variable "engine_version" {
  type        = string
  default     = "14"
  description = "Database engine version"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Database instance class"
}

variable "db_name" {
  type        = string
  default     = "strapidb"
  description = "Database name"
}

variable "db_username" {
  type        = string
  default     = "strapiuser"
  description = "Database username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Skip final snapshot before destroying"
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Make database publicly accessible"
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ deployment"
}
