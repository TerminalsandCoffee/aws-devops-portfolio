output "cluster_id" {
  description = "Identifier of the EKS cluster"
  value       = module.eks_core.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  value       = module.eks_core.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the EKS cluster"
  value       = module.eks_core.cluster_certificate_authority_data
}

output "node_group_role_arn" {
  description = "IAM role ARN associated with the default managed node group"
  value       = module.eks_core.eks_managed_node_groups["default"].iam_role_arn
}

output "prometheus_policy_arn" {
  description = "ARN of the IAM policy allowing Prometheus to publish metrics to CloudWatch"
  value       = var.create_prometheus_policy ? aws_iam_policy.prometheus_cloudwatch[0].arn : null
}
