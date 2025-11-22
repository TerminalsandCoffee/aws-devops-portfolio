# DMS (Database Migration Service) replication configuration

# DMS Subnet Group
resource "aws_dms_replication_subnet_group" "main" {
  replication_subnet_group_id          = "${var.project_name}-dms-subnet-group"
  replication_subnet_group_description = "Subnet group for DMS replication instance"
  subnet_ids                          = aws_subnet.private[*].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-dms-subnet-group"
    }
  )
}

# DMS Replication Instance
resource "aws_dms_replication_instance" "main" {
  replication_instance_id    = "${var.project_name}-dms-instance"
  replication_instance_class = var.dms_instance_class
  allocated_storage          = var.dms_allocated_storage

  vpc_security_group_ids  = [aws_security_group.dms.id]
  replication_subnet_group_id = aws_dms_replication_subnet_group.main.id
  publicly_accessible         = false

  # Multi-AZ for high availability (optional, costs more)
  multi_az = var.environment == "prod"

  # Maintenance window
  preferred_maintenance_window = "mon:04:00-mon:05:00"

  # Enable auto minor version upgrade
  auto_minor_version_upgrade = true

  # Apply immediately for changes
  apply_immediately = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-dms-instance"
    }
  )
}

# DMS Source Endpoint (RDS MySQL)
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "${var.project_name}-source-endpoint"
  endpoint_type = "source"
  engine_name   = "mysql"

  # Connection settings
  server_name   = aws_db_instance.source.address
  port          = 3306
  database_name = var.rds_db_name
  username      = var.rds_username
  password      = var.rds_password != "" ? var.rds_password : random_password.rds_password[0].result

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-source-endpoint"
    }
  )
}

# DMS Target Endpoint (Aurora MySQL)
resource "aws_dms_endpoint" "target" {
  endpoint_id   = "${var.project_name}-target-endpoint"
  endpoint_type = "target"
  engine_name   = "aurora"

  # Connection settings
  server_name   = aws_rds_cluster.aurora.endpoint
  port          = 3306
  database_name = var.rds_db_name
  username      = var.rds_username
  password      = var.rds_password != "" ? var.rds_password : random_password.aurora_password[0].result

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-target-endpoint"
    }
  )
}

# Note: DMS endpoints use direct username/password for simplicity
# In production, consider using Secrets Manager integration with proper IAM roles

# DMS Replication Task
resource "aws_dms_replication_task" "main" {
  migration_type           = "cdc"  # Change Data Capture for continuous replication
  replication_instance_arn = aws_dms_replication_instance.main.replication_instance_arn
  replication_task_id      = "${var.project_name}-replication-task"

  source_endpoint_arn = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn = aws_dms_endpoint.target.endpoint_arn

  table_mappings = jsonencode({
    rules = [{
      rule-type = "selection"
      rule-id   = "1"
      rule-name = "1"
      object-locator = {
        schema-name = var.rds_db_name
        table-name  = "%"
      }
      rule-action = "include"
    }]
  })

  cdc_start_position = "LATEST"  # Start from current position

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-replication-task"
    }
  )

  depends_on = [
    aws_dms_replication_instance.main,
    aws_dms_endpoint.source,
    aws_dms_endpoint.target
  ]
}

# CloudWatch Log Group for DMS
resource "aws_cloudwatch_log_group" "dms" {
  name              = "/aws/dms/${var.project_name}-replication-task"
  retention_in_days = 7

  tags = var.common_tags
}