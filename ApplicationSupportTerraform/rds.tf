
# Control whether RDS is created
variable "enable_rds" {
  description = "Whether to create the RDS database"
  type        = bool
  default     = false
}

# RDS PostgreSQL database
resource "aws_db_instance" "application" {
  count = var.enable_rds ? 1 : 0

  identifier = "application-support-db"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "application_support"
  username = "appadmin"

  manage_master_user_password = true

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true

  tags = {
    Name        = "Application-Support-RDS"
    Environment = "Development"
  }
}
