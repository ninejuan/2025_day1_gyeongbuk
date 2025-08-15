# VPC Peering Connection
resource "aws_vpc_peering_connection" "main" {
  vpc_id      = var.hub_vpc_id
  peer_vpc_id = var.app_vpc_id
  auto_accept = true

  tags = {
    Name = var.peering_name
  }
}

# Route table for Hub VPC to App VPC
resource "aws_route" "hub_to_app" {
  route_table_id            = var.hub_route_table_id
  destination_cidr_block    = var.app_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

# Route table for App VPC to Hub VPC
resource "aws_route" "app_to_hub" {
  route_table_id            = var.app_route_table_id
  destination_cidr_block    = var.hub_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
} 