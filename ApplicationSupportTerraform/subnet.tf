
locals {
  subnets = {
    public_1 = {
      cidr   = "10.0.1.0/24"
      az     = "eu-west-2a"
      public = true
    }
    public_2 = {
      cidr   = "10.0.2.0/24"
      az     = "eu-west-2b"
      public = true
    }
    app_1 = {
      cidr   = "10.0.11.0/24"
      az     = "eu-west-2a"
      public = false
    }
    app_2 = {
      cidr   = "10.0.12.0/24"
      az     = "eu-west-2b"
      public = false
    }
    db_1 = {
      cidr   = "10.0.21.0/24"
      az     = "eu-west-2a"
      public = false
    }
    db_2 = {
      cidr   = "10.0.22.0/24"
      az     = "eu-west-2b"
      public = false
    }
  }
}

resource "aws_subnet" "main" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = "Application-Support-${each.key}"
  }
}
