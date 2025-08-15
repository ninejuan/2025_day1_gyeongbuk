# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = values(aws_subnet.public)[0].id

  tags = {
    Name = "${var.vpc_name}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = "${data.aws_region.current.name}${each.value.az}"
  map_public_ip_on_launch = true

  tags = {
    Name = each.key
    Type = "Public"
  }
}

# Inspection Subnets (if defined)
resource "aws_subnet" "inspection" {
  for_each = var.inspection_subnets != null ? var.inspection_subnets : {}

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = each.key
    Type = "Inspection"
  }
}

# Workload Subnets (if defined)
resource "aws_subnet" "workload" {
  for_each = var.workload_subnets != null ? var.workload_subnets : {}

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = each.key
    Type = "Workload"
  }
}

# DB Subnets (if defined)
resource "aws_subnet" "db" {
  for_each = var.db_subnets != null ? var.db_subnets : {}

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = each.key
    Type = "Database"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.create_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "workload" {
  for_each = var.workload_subnets != null ? aws_subnet.workload : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db" {
  for_each = var.db_subnets != null ? aws_subnet.db : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Data sources
data "aws_region" "current" {} 