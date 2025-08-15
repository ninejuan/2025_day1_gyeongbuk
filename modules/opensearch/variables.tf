# Note: VPC and security group variables removed for public access

variable "domain_name" {
  description = "OpenSearch domain name"
  type        = string
}

variable "engine_version" {
  description = "OpenSearch engine version"
  type        = string
  default     = "OpenSearch_2.19"
}

variable "data_node_instance_type" {
  description = "Data node instance type"
  type        = string
  default     = "r7g.medium.search"
}

variable "data_node_count" {
  description = "Number of data nodes"
  type        = number
  default     = 2
}

variable "master_node_count" {
  description = "Number of master nodes"
  type        = number
  default     = 3
}

variable "master_username" {
  description = "Master username"
  type        = string
}

variable "master_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
} 