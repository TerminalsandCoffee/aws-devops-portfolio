# ──────────────────────────────────────────────────────────────
# Project-level variables (override per environment if needed)
# ──────────────────────────────────────────────────────────────
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "app_name" {
  description = "Base name for all resources"
  type        = string
  default     = "flask-ecs-demo"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "az_count" {
  description = "Number of AZs"
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Create NAT GW for private subnets"
  type        = bool
  default     = false   # Fargate only needs public subnets
}