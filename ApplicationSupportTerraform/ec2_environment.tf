
locals {
  rds_endpoint = var.enable_rds ? aws_db_instance.application[0].address : ""

  rds_secret_arn = var.enable_rds ? aws_db_instance.application[0].master_user_secret[0].secret_arn : ""
}
