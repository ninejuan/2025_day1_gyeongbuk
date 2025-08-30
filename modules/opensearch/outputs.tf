output "domain_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = aws_opensearch_domain.main.endpoint
}

output "domain_arn" {
  description = "OpenSearch domain ARN"
  value       = aws_opensearch_domain.main.arn
}

output "domain_id" {
  description = "OpenSearch domain ID"
  value       = aws_opensearch_domain.main.domain_id
}

output "dashboard_url" {
  description = "OpenSearch Dashboard URL"
  value       = "https://${aws_opensearch_domain.main.endpoint}/_dashboards/"
}

output "master_username" {
  description = "Master username for OpenSearch"
  value       = var.master_username
}

output "master_password" {
  description = "Master password for OpenSearch"
  value       = var.master_password
  sensitive   = true
}
