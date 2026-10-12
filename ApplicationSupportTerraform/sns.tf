
# SNS topic for application monitoring alerts
resource "aws_sns_topic" "alerts" {
  name = "Application-Support-Alerts"

  tags = {
    Name        = "Application-Support-Alerts"
    Environment = "Development"
    Project     = "ApplicationSupportTicketingSystem"
  }
}



variable "alert_email" {
  description = "Email address for application alerts"
  type        = string
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
