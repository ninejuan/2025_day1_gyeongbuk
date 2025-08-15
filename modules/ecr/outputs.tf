output "repository_urls" {
  description = "Map of ECR repository URLs"
  value       = { for k, v in aws_ecr_repository.repositories : k => v.repository_url }
}

output "repository_arns" {
  description = "Map of ECR repository ARNs"
  value       = { for k, v in aws_ecr_repository.repositories : k => v.arn }
} 