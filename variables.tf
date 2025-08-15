variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "skills-competition"
}

variable "region_code" {
  description = "Region code for resource naming"
  type        = string
  default     = "gyeongbuk"
} 