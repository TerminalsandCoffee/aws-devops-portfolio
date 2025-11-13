output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "argocd_url" {
  value = kubernetes_service.argocd_server.metadata[0].name
}
