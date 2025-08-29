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
# App VPC용 기본 public 라우트 테이블 (Hub VPC에서는 사용 안함)
resource "aws_route_table" "public" {
  count = var.inspection_subnets == null ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Hub VPC: Inspection subnet route table (IGW로 라우팅)
resource "aws_route_table" "inspection" {
  count = var.inspection_subnets != null ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-inspection-rt"
  }
}

# App VPC: Workload/DB subnet route table (NAT로 라우팅)
resource "aws_route_table" "private" {
  count = var.create_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# Hub VPC: Public subnet AZ별 라우트 테이블 (수동 연결용)
resource "aws_route_table" "public_az_a" {
  count = var.inspection_subnets != null ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-public-az-a-rt"
  }
}

resource "aws_route_table" "public_az_b" {
  count = var.inspection_subnets != null ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-public-az-b-rt"
  }
}

# Route Table Associations
# App VPC: Public subnets -> IGW
resource "aws_route_table_association" "public" {
  for_each = var.inspection_subnets == null ? aws_subnet.public : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}

# Hub VPC: Public subnets -> AZ별 라우트 테이블 (Network Firewall에서 관리)
resource "aws_route_table_association" "public_az_a" {
  for_each = var.inspection_subnets != null ? { "skills-hub-subnet-a" = aws_subnet.public["skills-hub-subnet-a"] } : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_az_a[0].id
}

resource "aws_route_table_association" "public_az_b" {
  for_each = var.inspection_subnets != null ? { "skills-hub-subnet-b" = aws_subnet.public["skills-hub-subnet-b"] } : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_az_b[0].id
}

# Hub VPC: Inspection subnets -> IGW
resource "aws_route_table_association" "inspection" {
  for_each = var.inspection_subnets != null ? aws_subnet.inspection : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.inspection[0].id
}

# App VPC: Workload subnets -> NAT
resource "aws_route_table_association" "workload" {
  for_each = var.workload_subnets != null && var.create_nat_gateway ? aws_subnet.workload : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}

# App VPC: DB subnets -> NAT
resource "aws_route_table_association" "db" {
  for_each = var.db_subnets != null && var.create_nat_gateway ? aws_subnet.db : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}

# Data sources
data "aws_region" "current" {} 