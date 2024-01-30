# File: autoscaling/main.tf

resource "aws_launch_configuration" "main" {
  name            = "web-server-launch-configuration"
  image_id        = "ami-12345678" # Replace with your desired AMI ID
  instance_type   = "t2.micro"     # Replace with your desired instance type
  security_groups = [aws_security_group.main.id]
  key_name        = var.key_name
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  launch_configuration = aws_launch_configuration.main.id
  vpc_zone_identifier  = var.public_subnet_ids
}

resource "aws_security_group" "main" {
  vpc_id = var.vpc_id

  # Define security group rules as needed
  # Example: allow ingress on port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Additional security group rules as needed
}

resource "aws_iam_role" "autoscaling_role" {
  name = "autoscaling_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "autoscaling.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "autoscaling_instance_profile" {
  name = "autoscaling_instance_profile"
  role = aws_iam_role.autoscaling_role.name
}

resource "aws_autoscaling_policy" "scale_out" {
  name                      = "scale_out"
  scaling_adjustment        = var.scaling_adjustment
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = var.cooldown
  cooldown_action           = "notify"
  estimated_instance_warmup = var.estimated_instance_warmup
  scaling_target_id         = aws_autoscaling_target.target.id
}

resource "aws_autoscaling_target" "target" {
  max_capacity       = var.max_size
  min_capacity       = var.min_size
  resource_id        = aws_autoscaling_group.main.id
  scalable_dimension = "autoscaling:AutoScalingGroup:DesiredCapacity"
  service_namespace  = "ec2"
}

# Additional resources as needed
