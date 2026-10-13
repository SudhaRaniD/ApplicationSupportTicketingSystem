
# S3 Gateway VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.main.id

  service_name = "com.amazonaws.eu-west-2.s3"

  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_app.id
  ]

  tags = {
    Name = "Application-Support-S3-Endpoint"
  }
}
