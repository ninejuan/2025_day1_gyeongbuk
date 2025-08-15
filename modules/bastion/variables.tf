variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for bastion host"
  type        = string
}

variable "instance_name" {
  description = "Name of the bastion instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.small"
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "login_password" {
  description = "Login password for the bastion host"
  type        = string
  sensitive   = true
}

variable "ssh_port" {
  description = "SSH port number"
  type        = number
  default     = 22
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
} 