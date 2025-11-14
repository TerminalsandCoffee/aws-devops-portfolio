output "rds_endpoint" {
  description = "Endpoint of the source RDS MySQL instance"
  value       = aws_db_instance.source.address
}

output "aurora_endpoint" {
  description = "Writer endpoint of the Aurora MySQL cluster"
  value       = aws_rds_cluster.aurora.endpoint
}