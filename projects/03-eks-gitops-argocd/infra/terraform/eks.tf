module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  # Enable Container Insights
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Fargate profiles – one for ArgoCD, one for the app
  fargate_profiles = {
    argocd = {
      name      = "argocd"
      selectors = [{ namespace = "argocd" }]
    }
    app = {
      name      = "app"
      selectors = [{ namespace = "app" }]
    }
  }

  # IAM role for cluster (least-privilege)
  create_cluster_primary_security_group = true
}