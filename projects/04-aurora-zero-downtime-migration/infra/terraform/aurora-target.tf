# Aurora MySQL-compatible cluster + instances

# Secrets Manager secret for Aurora credentials
resource "aws_secretsmanager_secret" "aurora_credentials" {
  name        = "${var.project_name}-aurora-credentials"
  description = "Aurora MySQL master credentials"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-aurora-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "aurora_credentials" {
  secret_id = aws_secretsmanager_secret.aurora_credentials.id
  secret_string = jsonencode({
    username = var.rds_username
    password = var.rds_password != "" ? var.rds_password : random_password.aurora_password[0].result
    engine   = "aurora-mysql"
    host     = aws_rds_cluster.aurora.endpoint
    port     = 3306
    dbname   = var.rds_db_name
  })
}

# Aurora MySQL Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.project_name}-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = var.aurora_engine_version
  database_name           = var.rds_db_name
  master_username         = var.rds_username
  master_password         = var.rds_password != "" ? var.rds_password : random_password.aurora_password[0].result

  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  # Backup configuration
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"
  preferred_maintenance_window = "mon:04:00-mon:05:00"

  # Enable CloudWatch logs
  enabled_cloudwatch_logs_exports = ["error", "general", "slow_query", "audit"]

  # Storage encryption
  storage_encrypted = true
  kms_key_id       = aws_kms_key.aurora.arn

  # Final snapshot
  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = "${var.project_name}-aurora-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  deletion_protection       = var.environment == "prod"

  # Serverless v2 scaling (optional - can use provisioned instead)
  # serverlessv2_scaling_configuration {
  #   max_capacity = 16
  #   min_capacity = 0.5
  # }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-aurora-cluster"
      Role = "Target"
    }
  )
}

# Aurora Cluster Instances
resource "aws_rds_cluster_instance" "aurora" {
  count              = var.aurora_cluster_instances
  identifier         = "${var.project_name}-aurora-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.aurora_instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  # Performance Insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.aurora_monitoring.arn

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-aurora-instance-${count.index + 1}"
      Role = "Target"
    }
  )
}

# KMS Key for Aurora encryption
resource "aws_kms_key" "aurora" {
  description             = "KMS key for Aurora encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-aurora-kms"
    }
  )
}

resource "aws_kms_alias" "aurora" {
  name          = "alias/${var.project_name}-aurora"
  target_key_id = aws_kms_key.aurora.key_id
}

# IAM Role for Aurora Enhanced Monitoring
resource "aws_iam_role" "aurora_monitoring" {
  name = "${var.project_name}-aurora-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "aurora_monitoring" {
  role       = aws_iam_role.aurora_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}