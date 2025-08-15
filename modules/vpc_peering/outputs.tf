output "peering_connection_id" {
  description = "VPC Peering Connection ID"
  value       = aws_vpc_peering_connection.main.id
}

output "peering_connection_status" {
  description = "VPC Peering Connection status"
  value       = aws_vpc_peering_connection.main.accept_status
} 