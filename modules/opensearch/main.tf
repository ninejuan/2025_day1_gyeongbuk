# OpenSearch Domain
resource "aws_opensearch_domain" "main" {
  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type            = var.data_node_instance_type
    instance_count           = var.data_node_count
    zone_awareness_enabled   = true
    dedicated_master_enabled = true
    dedicated_master_count   = var.master_node_count
    dedicated_master_type    = "r7g.medium.search"

    zone_awareness_config {
      availability_zone_count = var.data_node_count
    }
  }

  # Note: VPC options removed for public access

  ebs_options {
    ebs_enabled = true
    volume_size = 20
    volume_type = "gp3"
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = var.master_username
      master_user_password = var.master_password
    }
  }

  auto_tune_options {
    desired_state = "ENABLED"
    maintenance_schedule {
      start_at = timeadd(timestamp(), "24h")
      duration {
        value = 2
        unit  = "HOURS"
      }
      cron_expression_for_recurrence = "cron(0 0 ? * 1 *)"
    }
  }

  tags = {
    Name = var.domain_name
  }
}
