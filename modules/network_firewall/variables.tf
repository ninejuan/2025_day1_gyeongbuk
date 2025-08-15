variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "inspection_subnet_ids" {
  description = "List of inspection subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID"
  type        = string
}

variable "firewall_name" {
  description = "Name of the Network Firewall"
  type        = string
}

variable "policy_name" {
  description = "Name of the Network Firewall Policy"
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