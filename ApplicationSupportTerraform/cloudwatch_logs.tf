
# CloudWatch Log Group for FastAPI Application
resource "aws_cloudwatch_log_group" "application" {
  name              = "/application-support/fastapi"
  retention_in_days = 7

  tags = {
    Name        = "Application-Support-FastAPI-Logs"
    Environment = "Development"
  }
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/application-support-alert-handler"
  retention_in_days = 7

  tags = {
    Name        = "Application-Support-Lambda-Logs"
    Environment = "Development"
  }
}
