# VPC Outputs
output "hub_vpc_id" {
  description = "Hub VPC ID"
  value       = module.hub_vpc.vpc_id
}

output "app_vpc_id" {
  description = "Application VPC ID"
  value       = module.app_vpc.vpc_id
}

# Bastion Outputs
output "bastion_public_ip" {
  description = "Bastion server public IP"
  value       = module.bastion.bastion_public_ip
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion"
  value       = "ssh -p 2025 -i modules/bastion/ssh/skills-bastion-key ec2-user@${module.bastion.bastion_public_ip}"
}

# RDS Outputs
output "rds_cluster_endpoint" {
  description = "RDS cluster endpoint"
  value       = module.rds.cluster_endpoint
}

output "rds_cluster_identifier" {
  description = "RDS cluster identifier"
  value       = module.rds.cluster_identifier
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

# Load Balancer Outputs
output "external_nlb_dns" {
  description = "External NLB DNS name"
  value       = module.load_balancers.external_nlb_dns
}

output "internal_alb_dns" {
  description = "Internal ALB DNS name"
  value       = module.load_balancers.internal_alb_dns
}

# OpenSearch Outputs
output "opensearch_domain_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = module.opensearch.domain_endpoint
}

output "opensearch_dashboard_url" {
  description = "OpenSearch dashboard URL"
  value       = module.opensearch.dashboard_url
}

output "opensearch_username" {
  description = "OpenSearch master username"
  value       = module.opensearch.master_username
}

output "opensearch_password" {
  description = "OpenSearch master password"
  value       = module.opensearch.master_password
  sensitive   = true
}

# S3 Outputs
output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
}

# ECR Outputs
output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.ecr.repository_urls
} 