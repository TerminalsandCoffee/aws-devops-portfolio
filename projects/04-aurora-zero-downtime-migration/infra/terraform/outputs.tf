# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

# RDS Source Outputs
output "rds_endpoint" {
  description = "Endpoint of the source RDS MySQL instance"
  value       = aws_db_instance.source.address
}

output "rds_port" {
  description = "Port of the source RDS MySQL instance"
  value       = aws_db_instance.source.port
}

output "rds_secret_arn" {
  description = "ARN of the RDS credentials secret"
  value       = aws_secretsmanager_secret.rds_credentials.arn
  sensitive   = true
}

# Aurora Target Outputs
output "aurora_endpoint" {
  description = "Writer endpoint of the Aurora MySQL cluster"
  value       = aws_rds_cluster.aurora.endpoint
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint of the Aurora MySQL cluster"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "aurora_port" {
  description = "Port of the Aurora MySQL cluster"
  value       = aws_rds_cluster.aurora.port
}

output "aurora_secret_arn" {
  description = "ARN of the Aurora credentials secret"
  value       = aws_secretsmanager_secret.aurora_credentials.arn
  sensitive   = true
}

# DMS Outputs
output "dms_replication_instance_arn" {
  description = "ARN of the DMS replication instance"
  value       = aws_dms_replication_instance.main.replication_instance_arn
}

output "dms_replication_task_arn" {
  description = "ARN of the DMS replication task"
  value       = aws_dms_replication_task.main.replication_task_arn
}

output "dms_source_endpoint_arn" {
  description = "ARN of the DMS source endpoint"
  value       = aws_dms_endpoint.source.endpoint_arn
}

output "dms_target_endpoint_arn" {
  description = "ARN of the DMS target endpoint"
  value       = aws_dms_endpoint.target.endpoint_arn
}

# Route 53 Outputs
output "route53_record_name" {
  description = "Route 53 record name (if configured)"
  value       = var.route53_zone_name != "" ? aws_route53_record.database[0].fqdn : null
}

# Security Group Outputs
output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

output "aurora_security_group_id" {
  description = "Security group ID for Aurora"
  value       = aws_security_group.aurora.id
}

output "dms_security_group_id" {
  description = "Security group ID for DMS"
  value       = aws_security_group.dms.id
}

# Connection Strings (for reference)
output "rds_connection_string" {
  description = "RDS connection string template"
  value       = "mysql://${var.rds_username}@${aws_db_instance.source.address}:3306/${var.rds_db_name}"
  sensitive   = true
}

output "aurora_connection_string" {
  description = "Aurora connection string template"
  value       = "mysql://${var.rds_username}@${aws_rds_cluster.aurora.endpoint}:3306/${var.rds_db_name}"
  sensitive   = true
}