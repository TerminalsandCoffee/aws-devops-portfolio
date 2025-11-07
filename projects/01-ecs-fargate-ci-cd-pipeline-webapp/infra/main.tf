locals {
  name = var.app_name
  tags = {
    Project   = var.app_name
    ManagedBy = "Terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name               = local.name
  cidr               = var.vpc_cidr
  az_count           = var.az_count
  enable_nat_gateway = false   # Fargate = public subnets only
  single_nat_gateway = true
}

# ─────────────────────────────────────
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

module "alb" {
  source = "../../modules/alb"

  name         = local.name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnet_ids
  health_check_path = "/"
  # certificate_arn = "arn:aws:acm:..."  # optional later
}