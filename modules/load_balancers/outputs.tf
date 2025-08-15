output "internal_alb_dns" {
  description = "Internal ALB DNS name"
  value       = aws_lb.internal.dns_name
}

output "internal_alb_arn" {
  description = "Internal ALB ARN"
  value       = aws_lb.internal.arn
}

output "internal_nlb_dns" {
  description = "Internal NLB DNS name"
  value       = aws_lb.internal_nlb.dns_name
}

output "external_nlb_dns" {
  description = "External NLB DNS name"
  value       = aws_lb.external.dns_name
}

output "green_target_group_arn" {
  description = "Green target group ARN"
  value       = aws_lb_target_group.green.arn
}

output "red_target_group_arn" {
  description = "Red target group ARN"
  value       = aws_lb_target_group.red.arn
} 