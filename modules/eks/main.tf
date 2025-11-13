locals {
  merged_tags = merge(
    {
      Environment = "demo"
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

module "eks_core" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnet_ids

  cluster_enabled_log_types       = var.control_plane_log_types
  cluster_endpoint_public_access  = var.enable_cluster_public_access
  cluster_endpoint_private_access = var.enable_cluster_private_access

  eks_managed_node_groups = {
    default = {
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size
      instance_types = var.node_group_instance_types

      block_device_mappings = {
        xvepd = {
          device_name = "/dev/xvepd"
          ebs = {
            volume_size = 20
            volume_type = "gp3"
            encrypted   = true
          }
        }
      }
    }
  }

  tags = local.merged_tags
}

resource "aws_iam_policy" "prometheus_cloudwatch" {
  count       = var.create_prometheus_policy ? 1 : 0
  name        = "${var.cluster_name}-prometheus-metrics"
  description = "Allow Prometheus to export metrics to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}
