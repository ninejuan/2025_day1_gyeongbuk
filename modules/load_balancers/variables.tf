variable "hub_vpc_id" {
  description = "Hub VPC ID"
  type        = string
}

variable "app_vpc_id" {
  description = "Application VPC ID"
  type        = string
}

variable "hub_public_subnet_ids" {
  description = "List of Hub VPC public subnet IDs"
  type        = list(string)
}

variable "app_workload_subnet_ids" {
  description = "List of Application VPC workload subnet IDs"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
} 