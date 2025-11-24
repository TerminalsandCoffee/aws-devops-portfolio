variable "aws_region" {
  type        = string
  description = "AWS region to deploy the RDS and Aurora resources"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
  default     = "aurora-migration"
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

# RDS Source Configuration
variable "rds_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "rds_engine_version" {
  type        = string
  description = "RDS MySQL engine version"
  default     = "5.7"
}

variable "rds_allocated_storage" {
  type        = number
  description = "RDS allocated storage in GB"
  default     = 20
}

variable "rds_db_name" {
  type        = string
  description = "RDS database name"
  default     = "eduphoria_demo"
}

variable "rds_username" {
  type        = string
  description = "RDS master username"
  default     = "admin"
  sensitive   = true
}

variable "rds_password" {
  type        = string
  description = "RDS master password (leave empty to auto-generate)"
  default     = ""
  sensitive   = true
}

# Aurora Target Configuration
variable "aurora_instance_class" {
  type        = string
  description = "Aurora instance class"
  default     = "db.t4g.medium"
}

variable "aurora_engine_version" {
  type        = string
  description = "Aurora MySQL engine version"
  default     = "8.0.mysql_aurora.3.04.0"
}

variable "aurora_cluster_instances" {
  type        = number
  description = "Number of Aurora cluster instances"
  default     = 2
}

# DMS Configuration
variable "dms_instance_class" {
  type        = string
  description = "DMS replication instance class"
  default     = "dms.t3.micro"
}

variable "dms_allocated_storage" {
  type        = number
  description = "DMS allocated storage in GB"
  default     = 20
}

# Route 53 Configuration
variable "route53_zone_name" {
  type        = string
  description = "Route 53 hosted zone name (optional)"
  default     = ""
}

variable "route53_record_name" {
  type        = string
  description = "Route 53 record name for database endpoint"
  default     = "db.eduphoria.ex"
}

# Common Tags
variable "common_tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default = {
    Project     = "Aurora-Zero-Downtime-Migration"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}