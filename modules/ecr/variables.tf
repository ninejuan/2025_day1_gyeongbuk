variable "repositories" {
  description = "Map of ECR repository configurations"
  type        = map(any)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
} 