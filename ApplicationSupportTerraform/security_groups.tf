
# Security Group for Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "Application-Support-ALB-SG"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Application-Support-ALB-SG"
  }
}

# Allow HTTP traffic to ALB
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Allow ALB outbound traffic
resource "aws_vpc_security_group_egress_rule" "alb_outbound" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Security Group for EC2 Application
resource "aws_security_group" "ec2" {
  name        = "Application-Support-EC2-SG"
  description = "Security group for FastAPI EC2"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Application-Support-EC2-SG"
  }
}

# Allow ALB to communicate with FastAPI
resource "aws_vpc_security_group_ingress_rule" "ec2_fastapi" {
  security_group_id            = aws_security_group.ec2.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}

# Allow EC2 outbound traffic
resource "aws_vpc_security_group_egress_rule" "ec2_outbound" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Security Group for RDS PostgreSQL
resource "aws_security_group" "rds" {
  name        = "Application-Support-RDS-SG"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Application-Support-RDS-SG"
  }
}

# Only EC2 application can connect to RDS
resource "aws_vpc_security_group_ingress_rule" "rds_postgres" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}
