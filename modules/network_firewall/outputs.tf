output "firewall_id" {
  description = "Network Firewall ID"
  value       = aws_networkfirewall_firewall.main.id
}

output "firewall_arn" {
  description = "Network Firewall ARN"
  value       = aws_networkfirewall_firewall.main.arn
}

output "policy_arn" {
  description = "Network Firewall Policy ARN"
  value       = aws_networkfirewall_firewall_policy.main.arn
}

output "network_firewall_endpoint_az_a_id" {
  description = "Network Firewall VPC Endpoint AZ A ID"
  value       = aws_vpc_endpoint.network_firewall_az_a.id
}

output "network_firewall_endpoint_az_b_id" {
  description = "Network Firewall VPC Endpoint AZ B ID"
  value       = aws_vpc_endpoint.network_firewall_az_b.id
}

output "public_az_a_route_table_id" {
  description = "Public AZ-a Route Table ID"
  value       = aws_route_table.public_az_a.id
}

output "public_az_b_route_table_id" {
  description = "Public AZ-b Route Table ID"
  value       = aws_route_table.public_az_b.id
}

output "igw_route_table_id" {
  description = "IGW Route Table ID"
  value       = aws_route_table.igw.id
} 