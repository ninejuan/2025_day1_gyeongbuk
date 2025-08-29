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
    values = ["skills-firewall (ap-northeast-2a)"]
  }

  depends_on = [aws_networkfirewall_firewall.main]
}

data "aws_vpc_endpoint" "network_firewall_az_b" {
  vpc_id = var.vpc_id

  filter {
    name   = "vpc-endpoint-type"
    values = ["GatewayLoadBalancer"]
  }

  filter {
    name   = "tag:Name"
    values = ["skills-firewall (ap-northeast-2b)"]
  }

  depends_on = [aws_networkfirewall_firewall.main]
}

 