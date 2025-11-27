variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "alb-path-routing-demo"
}

variable "vpc_cidr" {
  description = "CIDR block for the demo VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "linux_instance_type" {
  description = "Instance type for the Linux EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "windows_instance_type" {
  description = "Instance type for the Windows EC2 instance"
  type        = string
  default     = "t3.medium"
}

variable "common_tags" {
  description = "Map of common tags to apply to resources"
  type        = map(string)
  default     = {}
}
