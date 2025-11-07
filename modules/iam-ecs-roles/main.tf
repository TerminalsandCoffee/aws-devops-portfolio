# ──────────────────────────────────────────────────────────────
# ECS Task Execution Role (pulls ECR, logs to CloudWatch)
# ──────────────────────────────────────────────────────────────
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name}-ecs-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = var.trusted_service
      }
    }]
  })

  tags = {
    Name = "${var.name}-ecs-exec"
  }
}

# Attach AWS managed policy (required for ECR + CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ──────────────────────────────────────────────────────────────
# ECS Task Role (app-specific permissions)
# ──────────────────────────────────────────────────────────────
resource "aws_iam_role" "ecs_task" {
  name = "${var.name}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = var.trusted_service
      }
    }]
  })

  tags = {
    Name = "${var.name}-ecs-task"
  }
}

# Attach additional policies (e.g., S3 read, DynamoDB access)
resource "aws_iam_role_policy_attachment" "additional" {
  for_each   = toset(var.additional_task_policy_arns)
  role       = aws_iam_role.ecs_task.name
  policy_arn = each.value
}