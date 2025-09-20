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

variable "aws_region" {
  description = "AWS region for ECR login"
  type        = string
}

variable "build_contexts" {
  description = "Map of repository name to Docker build context directory"
  type        = map(string)
  default     = {}
}

variable "image_tag" {
  description = "Docker image tag to build and push"
  type        = string
  default     = "v1.0.0"
}