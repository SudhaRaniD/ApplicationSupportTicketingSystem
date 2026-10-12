
# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Application-Support-Public-RT"
  }
}

# Public subnet associations
resource "aws_route_table_association" "public" {
  for_each = toset(["public_1", "public_2"])

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.public.id
}

# Private application route table
# No NAT Gateway for now
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Application-Support-Private-App-RT"
  }
}

resource "aws_route_table_association" "private_app" {
  for_each = toset(["app_1", "app_2"])

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.private_app.id
}

# Private database route table
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Application-Support-Private-DB-RT"
  }
}

resource "aws_route_table_association" "private_db" {
  for_each = toset(["db_1", "db_2"])

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.private_db.id
}
