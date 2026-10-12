
# VPC ID
output "vpc_id" {
  description = "Application Support VPC ID"
  value       = aws_vpc.main.id
}

# Internet Gateway ID
output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

# Public Subnet IDs
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.main["public_1"].id,
    aws_subnet.main["public_2"].id
  ]
}

# Private Application Subnet IDs
output "private_app_subnet_ids" {
  description = "Private application subnet IDs"
  value = [
    aws_subnet.main["app_1"].id,
    aws_subnet.main["app_2"].id
  ]
}

# Private Database Subnet IDs
output "private_db_subnet_ids" {
  description = "Private database subnet IDs"
  value = [
    aws_subnet.main["db_1"].id,
    aws_subnet.main["db_2"].id
  ]
}

# RDS DB Subnet Group
output "db_subnet_group_name" {
  description = "RDS DB subnet group name"
  value       = aws_db_subnet_group.main.name
}

# SNS Topic ARN
output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.alerts.arn
}

# Security Group IDs
output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
