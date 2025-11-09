###############################
# ECS Fargate Task Variables  #
###############################

variable "name" {
  description = "Name prefix for all resources (e.g., 'flask-demo')"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecr_image_url" {
  description = "Full ECR image URL with tag (e.g., '123456789.dkr.ecr.us-east-1.amazonaws.com/app:latest')"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on (must match app and ALB listener)"
  type        = number
  default     = 5000

  validation {
    condition     = var.container_port >= 80 && var.container_port <= 65535
    error_message = "Container port must be a valid TCP port (80–65535)."
  }
}

variable "task_execution_role_arn" {
  description = "ARN of the task execution role (for pulling from ECR)"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role (for app permissions)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs (public for Fargate)"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB (for task SG rules)"
  type        = string
}

variable "desired_count" {
  description = "Number of running tasks"
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 1 && var.desired_count <= 10
    error_message = "Desired count must be between 1 and 10."
  }
}

variable "cpu" {
  description = "vCPU units for the task (e.g., 256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MiB for the task (e.g., 512)"
  type        = number
  default     = 512
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}