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

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
              systemctl restart httpd
              systemctl enable httpd
              EOF

  key_name = var.key_name

  # Add other configuration settings for your launch template
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
    module.load_balancer.target_group_arn,
  ]
}

resource "aws_security_group" "instance" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [module.load_balancer.lb_security_group.id]
  }
}
