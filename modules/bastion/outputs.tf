output "instance_id" {
  description = "Bastion instance ID"
  value       = aws_instance.bastion.id
}

output "public_ip" {
  description = "Bastion instance public IP"
  value       = aws_instance.bastion.public_ip
}

output "private_ip" {
  description = "Bastion instance private IP"
  value       = aws_instance.bastion.private_ip
}

output "key_name" {
  description = "Key pair name"
  value       = aws_key_pair.bastion.key_name
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.bastion.id
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.bastion.arn
} 