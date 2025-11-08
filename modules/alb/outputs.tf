output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "http_listener_arn" {
  value = var.certificate_arn != "" ? aws_lb_listener.http_redirect[0].arn : aws_lb_listener.http_forward[0].arn
}

output "https_listener_arn" {
  value = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : null
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb.id
}