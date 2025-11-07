output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}

output "ecs_task_execution_role_arn" {
  value = module.iam.task_execution_role_arn
}

output "ecs_task_role_arn" {
  value = module.iam.task_role_arn
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "app_url" {
  value = "http://${module.ecs.alb_dns_name}"
}