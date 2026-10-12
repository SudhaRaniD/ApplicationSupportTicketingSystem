
resource "aws_db_subnet_group" "main" {
  name        = "application-support-db-subnet-group"
  description = "Private DB subnets for Application Support"

  subnet_ids = [
    aws_subnet.main["db_1"].id,
    aws_subnet.main["db_2"].id
  ]

  tags = {
    Name = "Application-Support-DB-Subnet-Group"
  }
}
