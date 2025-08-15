output "secret_arn" {
  description = "Secrets Manager secret ARN"
  value       = aws_secretsmanager_secret.main.arn
}

output "secret_id" {
  description = "Secrets Manager secret ID"
  value       = aws_secretsmanager_secret.main.id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.secrets.arn
} 