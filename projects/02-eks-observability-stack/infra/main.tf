module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.cluster_name
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  public_subnet_tags = {
    "kubernetes.io/role/elb"                        = 1
    "kubernetes.io/cluster/${var.cluster_name}"     = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"               = 1
    "kubernetes.io/cluster/${var.cluster_name}"     = "shared"
  }
}

module "eks" {
  source = "../../../modules/eks"

  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnets
  node_group_min_size = 1
  node_group_max_size = 3

  node_group_desired_size    = var.desired_size
  node_group_instance_types  = var.instance_types
  control_plane_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  enable_cluster_public_access  = false
  enable_cluster_private_access = true

  tags = {
    Environment = "demo"
    Owner       = "devops-portfolio"
  }

  create_prometheus_policy = true
}