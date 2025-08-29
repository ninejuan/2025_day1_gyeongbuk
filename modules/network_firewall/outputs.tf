output "firewall_id" {
  description = "Network Firewall ID"
  value       = aws_networkfirewall_firewall.main.id
}

output "firewall_arn" {
  description = "Network Firewall ARN"
  value       = aws_networkfirewall_firewall.main.arn
}

output "policy_arn" {
  description = "Network Firewall Policy ARN"
  value       = aws_networkfirewall_firewall_policy.main.arn
}

 