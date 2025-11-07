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

module "iam" {
  source = "../../modules/iam-ecs-roles"

  name = local.name
  # Example: give task access to S3 bucket
  # additional_task_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
}

module "ecr" {
  source = "../../modules/ecr"

  name                 = local.name
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  keep_last_n_images   = 10
}

module "ecs" {
  source = "../../modules/ecs-fargate"

  name                     = local.name
  cluster_name             = "${local.name}-cluster"
  ecr_image_url            = "${module.ecr.repository_url}:latest"
  container_port           = 80
  task_execution_role_arn  = module.iam.task_execution_role_arn
  task_role_arn            = module.iam.task_role_arn
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnet_ids
  target_group_arn         = module.alb.target_group_arn
  desired_count            = 1
  alb_dns_name             = module.alb.alb_dns_name
}