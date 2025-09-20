# KMS Key for Secrets Manager
resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.secret_name}-kms-key"
  }
}

# Secrets Manager Secret
resource "aws_secretsmanager_secret" "main" {
  name       = var.secret_name
  kms_key_id = aws_kms_key.secrets.arn
  
  recovery_window_in_days = 0

  tags = {
    Name = var.secret_name
  }
}

# Secrets Manager Secret Version
resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = jsonencode(var.secrets)
} 