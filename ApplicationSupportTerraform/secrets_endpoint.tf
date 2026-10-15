
variable "enable_secrets_endpoint" {
  description = "Enable private access to AWS Secrets Manager"
  type        = bool
  default     = false
}

resource "aws_security_group" "secrets_endpoint" {
  count = var.enable_secrets_endpoint ? 1 : 0

  name_prefix = "application-support-secrets-"
  description = "Allow EC2 access to Secrets Manager endpoint"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Application-Support-Secrets-Endpoint-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "secrets_https" {
  count = var.enable_secrets_endpoint ? 1 : 0

  security_group_id            = aws_security_group.secrets_endpoint[0].id
  referenced_security_group_id = aws_security_group.ec2.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "HTTPS from application EC2 instances"
}

resource "aws_vpc_endpoint" "secrets_manager" {
  count = var.enable_secrets_endpoint ? 1 : 0

  vpc_id = aws_vpc.main.id

  service_name = "com.amazonaws.eu-west-2.secretsmanager"

  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.main["app_1"].id,
    aws_subnet.main["app_2"].id
  ]

  security_group_ids = [
    aws_security_group.secrets_endpoint[0].id
  ]

  private_dns_enabled = true

  tags = {
    Name = "Application-Support-SecretsManager-Endpoint"
  }
}
