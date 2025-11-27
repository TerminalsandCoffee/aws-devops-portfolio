// EKS control plane and managed node group sized for the sample app + observability stack.

module "eks" {
  source = "../../../modules/eks"

  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnets
  node_group_min_size = 1
  node_group_max_size = 3

  node_group_desired_size   = var.desired_size
  node_group_instance_types = var.instance_types
  control_plane_log_types   = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  enable_cluster_public_access  = false
  enable_cluster_private_access = true

  tags = local.common_tags

  create_prometheus_policy = true
}
