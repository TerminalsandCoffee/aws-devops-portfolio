variable "name" {
  description = "Base name for VPC and resources"
  type        = string
}

variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs (public + private subnets)"
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Create NAT GW (one per AZ)"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use only one NAT GW for all private subnets"
  type        = bool
  default     = false
}