

# Enable or disable Lambda deployment
variable "enable_lambda" {
  description = "Whether to deploy Lambda"
  type        = bool
  default     = false
}

# Package Python code as a ZIP
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda function
resource "aws_lambda_function" "alert_handler" {
  count = var.enable_lambda ? 1 : 0

  function_name = "application-support-alert-handler"

  role    = aws_iam_role.lambda_role.arn
  handler = "handler.lambda_handler"
  runtime = "python3.12"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 10
  memory_size = 128

  //logging_config {
  // log_group = aws_cloudwatch_log_group.lambda.name
  // }


  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.lambda.name
  }

  tags = {
    Name = "Application-Support-Alert-Lambda"
  }
}

# Allow SNS to invoke Lambda
resource "aws_lambda_permission" "allow_sns" {
  count = var.enable_lambda ? 1 : 0

  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alert_handler[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}

# Subscribe Lambda to SNS
resource "aws_sns_topic_subscription" "lambda" {
  count = var.enable_lambda ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.alert_handler[0].arn

  depends_on = [
    aws_lambda_permission.allow_sns
  ]
}
