variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "workload_subnet_ids" {
  description = "List of workload subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.32"
}

variable "app_nodegroup_name" {
  description = "Application node group name"
  type        = string
}

variable "app_instance_type" {
  description = "Application node group instance type"
  type        = string
  default     = "t3.medium"
}

variable "addon_nodegroup_name" {
  description = "Addon node group name"
  type        = string
}

variable "addon_instance_type" {
  description = "Addon node group instance type"
  type        = string
  default     = "t3.medium"
}

variable "fargate_profile_name" {
  description = "Fargate profile name"
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