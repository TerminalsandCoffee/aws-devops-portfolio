output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_id
}

output "configure_kubectl" {
  description = "Configure kubectl: run this command after deployment"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_id}"
}