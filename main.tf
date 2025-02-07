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
  
    