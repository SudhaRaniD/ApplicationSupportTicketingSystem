
# Allow EC2 to download the deployment ZIP from S3
resource "aws_iam_role_policy" "ec2_s3_access" {
  count = var.enable_s3 ? 1 : 0

  name = "Application-Support-S3-Read"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadDeploymentPackage"
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = [
          "${aws_s3_bucket.deployment[0].arn}/application-support-deployment.zip"
        ]
      }
    ]
  })
}
