variable "name" {
  description = "Base name for ALB and related resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB lives"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs (public recommended)"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (optional)"
  type        = string
  default     = ""
}

variable "health_check_path" {
  description = "Path for ALB health checks"
  type        = string
  default     = "/"
}

variable "target_group_port" {
  description = "Port that the target group uses to route traffic to targets"
  type        = number
  default     = 80
}

variable "enable_deletion_protection" {
  description = "Prevent accidental ALB deletion (enable in production)"
  type        = bool
  default     = false
}

variable "ssl_policy" {
  description = "TLS policy for the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "tags" {
  description = "Common tags applied to all ALB resources"
  type        = map(string)
  default     = {}
}