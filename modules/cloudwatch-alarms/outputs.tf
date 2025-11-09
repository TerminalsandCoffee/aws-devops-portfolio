output "alarm_arns" {
  value = [
    aws_cloudwatch_metric_alarm.high_cpu.arn,
    aws_cloudwatch_metric_alarm.unhealthy_tasks.arn
  ]
}