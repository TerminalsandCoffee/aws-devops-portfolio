variable "aws_region" {
  type        = string
  description = "AWS region to deploy the RDS and Aurora resources"
  default     = "us-east-1"
}

# Add DB name, instance class, usernames, etc. here