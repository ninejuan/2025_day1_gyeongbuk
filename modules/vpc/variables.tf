variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "inspection_subnets" {
  description = "Map of inspection subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = null
}

variable "workload_subnets" {
  description = "Map of workload subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = null
}

variable "db_subnets" {
  description = "Map of database subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = null
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateway"
  type        = bool
  default     = false
}



variable "project" {
  description = "Project name"
  type        = string
} 