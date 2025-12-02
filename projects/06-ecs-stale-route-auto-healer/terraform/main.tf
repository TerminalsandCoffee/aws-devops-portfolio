# terraform/main.tf

# 1. Network Data Sources
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_caller_identity" "current" {}

# 2. ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.cluster_name}-cluster"
}

# 3. IAM Roles (Task Execution & Task Role)
module "iam" {
  source = "../../../modules/iam-ecs-roles"

  name = var.cluster_name
  tags = {
    Project = "06-ecs-stale-route-auto-healer"
  }
}

# 4. ALB (Load Balancer)
module "alb" {
  source = "../../../modules/alb"

  name              = "${var.cluster_name}-alb"
  vpc_id            = data.aws_vpc.default.id
  subnet_ids        = data.aws_subnets.default.ids
  target_group_port = 80
  health_check_path = "/"
}

# 5. ECS Capacity Provider (ASG + Launch Template)
module "ecs_asg" {
  source = "../../../modules/ecs-ec2-asg"

  name          = var.cluster_name
  vpc_id        = data.aws_vpc.default.id
  subnet_ids    = data.aws_subnets.default.ids
  instance_type = "t3.small"
}

# 6. Cluster Capacity Provider Association
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [module.ecs_asg.capacity_provider_name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = module.ecs_asg.capacity_provider_name
  }
}

# 7. Task Definition (Nginx)
resource "aws_ecs_task_definition" "nginx" {
  family             = "${var.cluster_name}-task"
  network_mode       = "bridge"
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  cpu                = 256
  memory             = 256

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 0 # Dynamic port mapping
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.cluster_name}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "nginx"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])
}

# 8. ECS Service
resource "aws_ecs_service" "nginx" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 2

  capacity_provider_strategy {
    capacity_provider = module.ecs_asg.capacity_provider_name
    weight            = 100
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [module.alb]
}

# ------------------------------------------------------------------
# Auto-Healer Logic (Lambda + Alarm + EventBridge)
# ------------------------------------------------------------------

# 9. Lambda Function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/auto_heal_service.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "auto_healer" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.cluster_name}-auto-healer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "auto_heal_service.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 60

  environment {
    variables = {
      CLUSTER_NAME = aws_ecs_cluster.main.name
      SERVICE_NAME = aws_ecs_service.nginx.name
    }
  }
}

# 10. Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.cluster_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.cluster_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:StopTask",
          "ecs:UpdateService"
        ]
        Resource = [
          aws_ecs_cluster.main.arn,
          aws_ecs_service.nginx.id,
          "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task/${aws_ecs_cluster.main.name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeTargetHealth"
        ]
        Resource = "*"
      }
    ]
  })
}

# 11. CloudWatch Alarm (5xx Errors)
resource "aws_cloudwatch_metric_alarm" "http_5xx" {
  alarm_name          = "${var.cluster_name}-high-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5" # Trigger on >5 errors to prevent flapping
  alarm_description   = "Triggers when ALB sees 5xx errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    # Extract the ARN suffix for the LoadBalancer dimension
    # Format: app/load-balancer-name/load-balancer-id
    LoadBalancer = replace(module.alb.alb_arn, "/^arn:.*:loadbalancer\\/(.*)$/", "$1")
  }
}

# 12. EventBridge Rule (Trigger Lambda on Alarm)
resource "aws_cloudwatch_event_rule" "alarm_trigger" {
  name        = "${var.cluster_name}-alarm-trigger"
  description = "Triggers Lambda when 5xx Alarm fires"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail = {
      alarmName = [aws_cloudwatch_metric_alarm.http_5xx.alarm_name]
      state     = { value = ["ALARM"] }
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.alarm_trigger.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.auto_healer.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_healer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alarm_trigger.arn
}
