output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = values(aws_subnet.public)[*].id
}

output "inspection_subnet_ids" {
  description = "List of inspection subnet IDs"
  value       = var.inspection_subnets != null ? values(aws_subnet.inspection)[*].id : []
}

output "workload_subnet_ids" {
  description = "List of workload subnet IDs"
  value       = var.workload_subnets != null ? values(aws_subnet.workload)[*].id : []
}

output "db_subnet_ids" {
  description = "List of database subnet IDs"
  value       = var.db_subnets != null ? values(aws_subnet.db)[*].id : []
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = var.inspection_subnets == null ? aws_route_table.public[0].id : null
}

output "inspection_route_table_id" {
  description = "Inspection route table ID"
  value       = var.inspection_subnets != null ? aws_route_table.inspection[0].id : null
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = var.create_nat_gateway ? aws_route_table.private[0].id : null
}

output "public_az_a_route_table_id" {
  description = "Public AZ A route table ID"
  value       = var.inspection_subnets != null ? aws_route_table.public_az_a[0].id : null
}

output "public_az_b_route_table_id" {
  description = "Public AZ B route table ID"
  value       = var.inspection_subnets != null ? aws_route_table.public_az_b[0].id : null
} 