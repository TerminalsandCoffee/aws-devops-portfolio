# ALB Path Routing Demo - Outputs

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

# Application URLs
output "app1_url" {
  description = "URL for App1 (Linux/Nginx)"
  value       = "http://${aws_lb.main.dns_name}/app1/"
}

output "app2_url" {
  description = "URL for App2 (Windows/IIS)"
  value       = "http://${aws_lb.main.dns_name}/app2/"
}

# Test Commands
output "test_commands" {
  description = "Curl commands to test both applications"
  value = {
    app1 = "curl http://${aws_lb.main.dns_name}/app1/"
    app2 = "curl http://${aws_lb.main.dns_name}/app2/"
    default = "curl http://${aws_lb.main.dns_name}/"
  }
}

# Instance Information
output "linux_instance_id" {
  description = "Instance ID of Linux App1 instance"
  value       = aws_instance.linux_app1.id
}

output "linux_instance_private_ip" {
  description = "Private IP of Linux App1 instance"
  value       = aws_instance.linux_app1.private_ip
}

output "windows_instance_ids" {
  description = "Instance IDs of Windows App2 instances"
  value       = aws_instance.windows_app2[*].id
}

output "windows_instance_private_ips" {
  description = "Private IPs of Windows App2 instances"
  value       = aws_instance.windows_app2[*].private_ip
}

# Target Group Information
output "target_group_app1_arn" {
  description = "ARN of App1 target group"
  value       = aws_lb_target_group.app1.arn
}

output "target_group_app2_arn" {
  description = "ARN of App2 target group"
  value       = aws_lb_target_group.app2.arn
}

# Network Information
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

# Security Group Information
output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "Security group ID for EC2 instances"
  value       = aws_security_group.ec2.id
}
