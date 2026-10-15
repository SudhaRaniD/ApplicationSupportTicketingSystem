
resource "aws_launch_template" "application" {
  name_prefix   = "application-support-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  # user_data     = base64encode(file("${path.module}/user_data.sh"))

  #user_data = base64encode(
  #  templatefile("${path.module}/user_data.sh", {
  #    s3_bucket_name = var.enable_s3 ? aws_s3_bucket.deployment[0].id : ""
  # })
  #)


  user_data = base64encode(
    templatefile("${path.module}/user_data.sh", {
      s3_bucket_name = var.enable_s3 ? aws_s3_bucket.deployment[0].id : ""
      rds_endpoint   = local.rds_endpoint
      rds_secret_arn = local.rds_secret_arn
    })
  )


  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Application-Support-ASG-EC2"
    }
  }
}
