variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the control plane"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC identifier where the cluster will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS worker nodes"
  type        = list(string)
}

variable "node_group_instance_types" {
  description = "EC2 instance types for the default managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "control_plane_log_types" {
  description = "Control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "enable_cluster_public_access" {
  description = "Expose the EKS cluster endpoint publicly"
  type        = bool
  default     = false
}

variable "enable_cluster_private_access" {
  description = "Enable private access to the EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to created resources"
  type        = map(string)
  default     = {}
}

variable "create_prometheus_policy" {
  description = "Whether to create an IAM policy that allows Prometheus to push metrics to CloudWatch"
  type        = bool
  default     = true
}
