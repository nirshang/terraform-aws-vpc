resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy = "default"

  # expense-dev
  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
      Name = local.resource_name
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  map_public_ip_on_launch = true 

  tags = merge(
   var.common_tags,
   var.public_subnet_tags,
   {
    Name = "${local.resource_name}-public-${local.azs[count.index]}"
   }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_tags,
    {
      Name = "${local.resource_name}-private-${local.azs[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
    {
      Name = "${local.resource_name}-database-${local.azs[count.index]}"
    }
  )
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
        Name = local.resource_name
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}