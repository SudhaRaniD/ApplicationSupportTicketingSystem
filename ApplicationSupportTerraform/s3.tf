
variable "enable_s3" {
  description = "Create S3 deployment bucket"
  type        = bool
  default     = false
}

resource "aws_s3_bucket" "deployment" {
  count = var.enable_s3 ? 1 : 0

  bucket_prefix = "application-support-deploy-"

  tags = {
    Name        = "Application-Support-Deployment"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_public_access_block" "deployment" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.deployment[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "deployment" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.deployment[0].id

  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "deployment" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.deployment[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
