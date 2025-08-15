variable "secret_name" {
  description = "Name of the secret"
  type        = string
}

variable "secrets" {
  description = "Map of secret key-value pairs"
  type        = map(string)
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