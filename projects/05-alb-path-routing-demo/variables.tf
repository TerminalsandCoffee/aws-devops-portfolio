variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
  default     = "alb-path-routing-demo"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
}

# VPC Configuration
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones for subnets"
  default     = ["us-east-1a", "us-east-1b"]
}

# EC2 Key Pair
variable "key_name" {
  type        = string
  description = "Name of the AWS EC2 Key Pair for SSH/RDP access"
  default     = ""
}

# Instance Configuration
variable "linux_instance_type" {
  type        = string
  description = "EC2 instance type for Linux (app1)"
  default     = "t3.micro"
}

variable "windows_instance_type" {
  type        = string
  description = "EC2 instance type for Windows (app2)"
  default     = "t3.medium"
}

variable "windows_instance_count" {
  type        = number
  description = "Number of Windows instances for App2 (high availability)"
  default     = 2
}

# Common Tags
variable "common_tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default = {
    Project     = "ALB-Path-Routing-Demo"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}
