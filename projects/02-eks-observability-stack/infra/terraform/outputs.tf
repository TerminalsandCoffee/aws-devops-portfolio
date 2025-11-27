output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_id
}

output "aws_region" {
  description = "AWS region where the cluster is deployed"
  value       = var.aws_region
}

output "cluster_oidc_provider" {
  description = "OIDC provider URL used for IRSA"
  value       = module.eks.oidc_provider
}

output "observability_irsa_role_arn" {
  description = "IAM role that the observability service account can assume"
  value       = aws_iam_role.observability_irsa.arn
}

output "configure_kubectl" {
  description = "Configure kubectl: run this command after deployment"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_id}"
}
