variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group monitored by the ALB"
  type        = string
}