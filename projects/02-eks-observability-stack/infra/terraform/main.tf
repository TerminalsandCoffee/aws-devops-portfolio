// Terraform entrypoint for the EKS observability stack.
// Networking, cluster, and IAM components are split into focused files for clarity.

locals {
  # Common tags that make demo resources easy to spot in the AWS console.
  common_tags = {
    Project     = var.cluster_name
    Repository  = "aws-devops-portfolio"
    Environment = "demo"
    ManagedBy   = "Terraform"
  }
}
