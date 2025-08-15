variable "hub_vpc_id" {
  description = "Hub VPC ID"
  type        = string
}

variable "app_vpc_id" {
  description = "Application VPC ID"
  type        = string
}

variable "hub_vpc_cidr" {
  description = "Hub VPC CIDR block"
  type        = string
}

variable "app_vpc_cidr" {
  description = "Application VPC CIDR block"
  type        = string
}

variable "hub_route_table_id" {
  description = "Hub VPC route table ID"
  type        = string
}

variable "app_route_table_id" {
  description = "Application VPC route table ID"
  type        = string
}

variable "peering_name" {
  description = "Name of the VPC peering connection"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
} 