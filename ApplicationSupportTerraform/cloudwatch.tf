
# Enable or disable CPU monitoring
variable "enable_cpu_alarm" {
  description = "Whether to create the EC2 CPU alarm"
  type        = bool
  default     = false
}

# CloudWatch alarm for high EC2 CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.enable_cpu_alarm && var.enable_ec2 ? 1 : 0

  alarm_name        = "Application-Support-High-CPU"
  alarm_description = "Alert when EC2 CPU exceeds 80 percent"

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    InstanceId = aws_instance.application[0].id
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "missing"

  tags = {
    Name = "Application-Support-High-CPU"
  }
}
