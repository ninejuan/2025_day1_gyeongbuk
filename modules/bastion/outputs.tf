output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion instance"
  value       = aws_eip.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion instance"
  value       = aws_instance.bastion.private_ip
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion.id
}

output "bastion_key_name" {
  description = "Name of the bastion key pair"
  value       = aws_key_pair.bastion.key_name
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.bastion.arn
} 