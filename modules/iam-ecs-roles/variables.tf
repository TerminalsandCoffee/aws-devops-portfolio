variable "name" {
  description = "Base name for roles and policies"
  type        = string
}

variable "additional_task_policy_arns" {
  description = "Extra managed policies for task role (e.g., S3, DynamoDB)"
  type        = list(string)
  default     = []
}

variable "trusted_service" {
  description = "Service that assumes the role (default: ecs-tasks.amazonaws.com)"
  type        = string
  default     = "ecs-tasks.amazonaws.com"
}

variable "tags" {
  description = "Common tags applied to IAM resources"
  type        = map(string)
  default     = {}
}