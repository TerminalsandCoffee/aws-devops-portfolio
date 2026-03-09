# Root module — resources are organized in dedicated files:
#   vpc.tf            – VPC and networking
#   eks.tf            – EKS cluster and Fargate profiles
#   argocd.tf         – ArgoCD Helm release
#   helm_providers.tf – Kubernetes/Helm provider config
#   outputs.tf        – All outputs
#   variables.tf      – All variables
#   versions.tf       – Terraform/provider versions + backend
#   provider.tf       – AWS provider
