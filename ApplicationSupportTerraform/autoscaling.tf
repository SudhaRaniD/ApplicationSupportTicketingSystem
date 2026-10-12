
variable "enable_autoscaling" {
  description = "Enable EC2 Auto Scaling"
  type        = bool
  default     = false
}

resource "aws_autoscaling_group" "application" {
  count = var.enable_autoscaling ? 1 : 0

  name = "application-support-asg"

  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  vpc_zone_identifier = [
    aws_subnet.main["app_1"].id,
    aws_subnet.main["app_2"].id
  ]

  launch_template {
    id      = aws_launch_template.application.id
    version = "$Latest"
  }

  target_group_arns = var.enable_alb ? [
    aws_lb_target_group.fastapi[0].arn
  ] : []

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "Application-Support-ASG-EC2"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_target" {
  count = var.enable_autoscaling ? 1 : 0

  name                   = "application-support-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.application[0].name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}
