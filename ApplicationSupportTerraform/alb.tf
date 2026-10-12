
# Enable or disable Application Load Balancer
variable "enable_alb" {
  description = "Whether to create the ALB"
  type        = bool
  default     = false
}

# Application Load Balancer
resource "aws_lb" "application" {
  count = var.enable_alb ? 1 : 0

  name               = "application-support-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.main["public_1"].id,
    aws_subnet.main["public_2"].id
  ]

  tags = {
    Name = "Application-Support-ALB"
  }
}

# Target group for FastAPI
resource "aws_lb_target_group" "fastapi" {
  count = var.enable_alb ? 1 : 0

  name        = "application-support-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "Application-Support-TG"
  }
}

# HTTP listener
resource "aws_lb_listener" "http" {
  count = var.enable_alb ? 1 : 0

  load_balancer_arn = aws_lb.application[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi[0].arn
  }
}

# Register EC2 instance with target group
resource "aws_lb_target_group_attachment" "fastapi" {
  count = var.enable_alb && var.enable_ec2 ? 1 : 0

  target_group_arn = aws_lb_target_group.fastapi[0].arn
  target_id        = aws_instance.application[0].id
  port             = 8000
}
