# terraform/outputs.tf

output "alb_dns_name" {
  description = "DNS name of the Load Balancer"
  value       = module.alb.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS Service"
  value       = aws_ecs_service.nginx.name
}

output "region" {
  description = "AWS Region"
  value       = var.region
}
