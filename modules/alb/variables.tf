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