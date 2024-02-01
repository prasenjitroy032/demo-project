# File: autoscaling/main.tf

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "main" {
  name                   = "web-server-launch-template"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  image_id = data.aws_ami.latest_amazon_linux.id

  user_data = filebase64("${path.module}/linux.sh")

  key_name = var.key_name

}

resource "aws_autoscaling_group" "main" {
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.private_subnet_ids
  health_check_type   = "ELB"
  target_group_arns = [
    #module.load_balancer.target_group_arn,
    var.lb_tg_arn
  ]
}

resource "aws_security_group" "instance" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    #security_groups = [module.load_balancer.lb_security_group.id]
    security_groups = [var.lb_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}