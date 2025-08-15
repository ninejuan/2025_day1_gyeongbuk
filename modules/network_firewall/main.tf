# Network Firewall Policy
resource "aws_networkfirewall_firewall_policy" "main" {
  name = var.policy_name

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_ifconfig_me.arn
    }
  }

  tags = {
    Name = var.policy_name
  }
}

# Network Firewall
resource "aws_networkfirewall_firewall" "main" {
  name                = var.firewall_name
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = var.vpc_id

  dynamic "subnet_mapping" {
    for_each = var.inspection_subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = {
    Name = var.firewall_name
  }
}

# Network Firewall Rule Group - Block ifconfig.me from Bastion
resource "aws_networkfirewall_rule_group" "block_ifconfig_me" {
  capacity = 100
  name     = "block-ifconfig-me"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types        = ["HTTP_HOST", "TLS_SNI"]
        targets             = ["ifconfig.me"]
      }
    }
  }

  tags = {
    Name = "block-ifconfig-me"
  }
}

# Data source for current region
data "aws_region" "current" {}

# Data source for Network Firewall auto-generated VPC Endpoints
data "aws_vpc_endpoint" "network_firewall_az_a" {
  vpc_id = var.vpc_id

  filter {
    name   = "vpc-endpoint-type"
    values = ["GatewayLoadBalancer"]
  }

  filter {
    name   = "tag:Name"
    values = ["*skills-firewall*ap-northeast-2a*"]
  }
}

data "aws_vpc_endpoint" "network_firewall_az_b" {
  vpc_id = var.vpc_id

  filter {
    name   = "vpc-endpoint-type"
    values = ["GatewayLoadBalancer"]
  }

  filter {
    name   = "tag:Name"
    values = ["*skills-firewall*ap-northeast-2b*"]
  }
}

# Route table for inspection subnets (Network Firewall)
resource "aws_route_table" "inspection" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name = "${var.firewall_name}-inspection-rt"
  }
}

# Route table associations for inspection subnets
resource "aws_route_table_association" "inspection" {
  count = length(var.inspection_subnet_ids)

  subnet_id      = var.inspection_subnet_ids[count.index]
  route_table_id = aws_route_table.inspection.id
}

# Route table for public subnets - Route to Network Firewall VPC Endpoint AZ A
resource "aws_route_table" "public_az_a" {
  vpc_id = var.vpc_id

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   vpc_endpoint_id = aws_vpc_endpoint.network_firewall_az_a.id
  # }

  tags = {
    Name = "${var.firewall_name}-public-az-a-rt"
  }
}

# Route table for public subnets - Route to Network Firewall VPC Endpoint AZ B
resource "aws_route_table" "public_az_b" {
  vpc_id = var.vpc_id

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   vpc_endpoint_id = aws_vpc_endpoint.network_firewall_az_b.id
  # }

  tags = {
    Name = "${var.firewall_name}-public-az-b-rt"
  }
}

# Route table associations for public subnets
resource "aws_route_table_association" "public_az_a" {
  subnet_id      = var.public_subnet_ids[0]
  route_table_id = aws_route_table.public_az_a.id
}

resource "aws_route_table_association" "public_az_b" {
  subnet_id      = var.public_subnet_ids[1]
  route_table_id = aws_route_table.public_az_b.id
}

# Route for public AZ A to Network Firewall VPC Endpoint (Auto-generated)
resource "aws_route" "public_az_a_to_firewall" {
  route_table_id         = aws_route_table.public_az_a.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.network_firewall_az_a.id

  depends_on = [aws_route_table_association.public_az_a, data.aws_vpc_endpoint.network_firewall_az_a]
}

# Route for public AZ B to Network Firewall VPC Endpoint (Auto-generated)
resource "aws_route" "public_az_b_to_firewall" {
  route_table_id         = aws_route_table.public_az_b.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.network_firewall_az_b.id

  depends_on = [aws_route_table_association.public_az_b, data.aws_vpc_endpoint.network_firewall_az_b]
}

# IGW Route Table for edge connection
resource "aws_route_table" "igw" {
  vpc_id = var.vpc_id


  # route {
  #   cidr_block = "10.0.0.0/24"
  #   vpc_endpoint_id = aws_vpc_endpoint.network_firewall_az_a.id
  # } 

  # route {
  #   cidr_block = "10.0.1.0/24"
  #   vpc_endpoint_id = aws_vpc_endpoint.network_firewall_az_b.id
  # }

  tags = {
    Name = "${var.firewall_name}-igw-rt"
  }
}

resource "aws_route" "igw_to_firewall_common" {
  route_table_id         = aws_route_table.igw.id
  destination_cidr_block = "0.0.0.0/0" # Or a more specific CIDR for inbound traffic
  gateway_id = var.internet_gateway_id
}

# Route for IGW to Network Firewall VPC Endpoint AZ A (Auto-generated)
resource "aws_route" "igw_to_firewall_az_a" {
  route_table_id         = aws_route_table.igw.id
  destination_cidr_block = "10.0.0.0/24"
  vpc_endpoint_id        = data.aws_vpc_endpoint.network_firewall_az_a.id

  depends_on = [aws_networkfirewall_firewall.main, data.aws_vpc_endpoint.network_firewall_az_a]
}

# Route for IGW to Network Firewall VPC Endpoint AZ B (Auto-generated)
resource "aws_route" "igw_to_firewall_az_b" {
  route_table_id         = aws_route_table.igw.id
  destination_cidr_block = "10.0.1.0/24"
  vpc_endpoint_id        = data.aws_vpc_endpoint.network_firewall_az_b.id

  depends_on = [aws_networkfirewall_firewall.main, data.aws_vpc_endpoint.network_firewall_az_b]
} 