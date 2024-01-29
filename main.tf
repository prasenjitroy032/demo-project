# File: main.tf (Terraform)

provider "aws" {
  region = "us-east-1" # Change this to your preferred AWS region
}

# 1. Create VPC, Internet Gateway, and Routes
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16" # Replace with your desired CIDR
}

# 2. Create Auto Scaling Group
module "autoscaling" {
  source  = "./modules/autoscaling"
  vpc_id  = module.vpc.vpc_id
}

# 3. Create Web Server Instance
module "web_server" {
  source  = "./modules/web_server"
  vpc_id  = module.vpc.vpc_id
}

# 4. Change Default Web Server TCP Port
resource "aws_security_group_rule" "web_server_port" {
  security_group_id = module.web_server.security_group_id
  type             = "ingress"
  from_port        = 8080
  to_port          = 8080
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
}

# 5. Create Load Balancer and Point to Web Server
module "load_balancer" {
  source      = "./modules/load_balancer"
  vpc_id      = module.vpc.vpc_id
  target_port = 8080
}

# 6. Open TCP Port 80 on Security Group
resource "aws_security_group_rule" "load_balancer_port" {
  security_group_id = module.load_balancer.security_group_id
  type             = "ingress"
  from_port        = 80
  to_port          = 80
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
}

# 7. Create IAM User and Grant Restart Web Server Access
resource "aws_iam_user" "web_server_user" {
  name = "web_server_user"
}

resource "aws_iam_policy" "restart_policy" {
  name        = "restart_policy"
  description = "Policy to restart web server"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["ec2:RebootInstances"],
        Resource = ["*"],
      },
    ],
  })
}

resource "aws_iam_user_policy_attachment" "web_server_user_policy" {
  user       = aws_iam_user.web_server_user.name
  policy_arn = aws_iam_policy.restart_policy.arn
}
