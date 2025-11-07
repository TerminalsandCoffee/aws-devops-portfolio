output "cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "service_name" {
  value = aws_ecs_service.main.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.main.arn
}

output "alb_dns_name" {
  description = "Pass-through from ALB module"
  value       = var.alb_dns_name
}