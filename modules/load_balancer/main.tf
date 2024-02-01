# File: load_balancer/main.tf

resource "aws_lb" "main" {
  name               = "web-server-lb"
  internal           = false # Set to true for internal load balancer
  load_balancer_type = "application"
  subnets            = var.subnet_ids

  enable_deletion_protection = false # Set to true if you want to enable deletion protection

  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  security_groups                  = [aws_security_group.lb_security_group.id]
}

resource "aws_security_group" "lb_security_group" {
  vpc_id = var.vpc_id

  # Allow all traffic on port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Additional security group rules as needed
}

resource "aws_lb_target_group" "main" {
  name        = "web-server-target-group"
  port        = var.target_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id


  health_check {
    interval            = 30
    path                = "/"
    port                = var.target_port
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 3600
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_autoscaling_attachment" "attach_lb" {
  #updated
  autoscaling_group_name = var.autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.main.arn
}
