output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "linux_instance_private_ip" {
  description = "Private IP of the Linux instance"
  value       = aws_instance.linux_app1.private_ip
}

output "windows_instance_private_ip" {
  description = "Private IP of the Windows instance"
  value       = aws_instance.windows_app2.private_ip
}
