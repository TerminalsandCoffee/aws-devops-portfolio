# RDS MySQL source instance definition

# Secrets Manager secret for RDS credentials
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "${var.project_name}-rds-credentials"
  description = "RDS MySQL master credentials"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-rds-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = var.rds_username
    password = var.rds_password != "" ? var.rds_password : random_password.rds_password[0].result
    engine   = "mysql"
    host     = aws_db_instance.source.address
    port     = 3306
    dbname   = var.rds_db_name
  })
}

# RDS MySQL Source Instance
resource "aws_db_instance" "source" {
  identifier     = "${var.project_name}-rds-source"
  engine         = "mysql"
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  allocated_storage     = var.rds_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.rds.arn

  db_name  = var.rds_db_name
  username = var.rds_username
  password = var.rds_password != "" ? var.rds_password : random_password.rds_password[0].result

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  # Backup configuration
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  # Enable binary logging for replication
  enabled_cloudwatch_logs_exports = ["error", "general", "slow_query"]
  
  # Enable automated backups
  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier  = "${var.project_name}-rds-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  deletion_protection       = var.environment == "prod"

  # Performance Insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  # Enable binlog for replication
  parameter_group_name = aws_db_parameter_group.rds.name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-rds-source"
      Role = "Source"
    }
  )
}

# RDS Parameter Group (enable binlog)
resource "aws_db_parameter_group" "rds" {
  name   = "${var.project_name}-rds-params"
  family = "mysql${replace(var.rds_engine_version, ".", "")}"

  parameter {
    name  = "binlog_format"
    value = "ROW"
  }

  parameter {
    name  = "binlog_checksum"
    value = "NONE"
  }

  parameter {
    name  = "log_bin"
    value = "ON"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-rds-params"
    }
  )
}

# KMS Key for RDS encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation      = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-rds-kms"
    }
  )
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-rds"
  target_key_id = aws_kms_key.rds.key_id
}