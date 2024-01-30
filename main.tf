# File: main.tf (Terraform)

provider "aws" {
  region = "us-east-1" # Change this to your preferred AWS region
}

# 1. Create VPC, Internet Gateway, and Routes
module "vpc" {
  source             = "./modules/vpc"
  cidr               = "10.0.0.0/16" # Replace with your desired CIDR
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# 2. Create Auto Scaling Group
module "autoscaling" {
  source            = "./modules/autoscaling"
  vpc_id            = module.vpc.vpc_id
  key_name          = test-linux
  min_size          = 1
  max_size          = 3
  public_subnet_ids = module.vpc.public_subnet_ids
}

# 3. Create Web Server Instance
#module "web_server" {
#  source = "./modules/web_server"
#  vpc_id = module.vpc.vpc_id
#}

# 4. Change Default Web Server TCP Port
#resource "aws_security_group_rule" "web_server_port" {
#  security_group_id = module.web_server.security_group_id
#  type              = "ingress"
#  from_port         = 8080
#  to_port           = 8080
#  protocol          = "tcp"
#  cidr_blocks       = ["0.0.0.0/0"]
#}

# 5. Create Load Balancer and Point to Web Server
module "load_balancer" {
  source        = "./modules/load_balancer"
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.public_subnet_ids
  target_port   = 8080
  listener_port = 80
}


# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = module.autoscaling.autoscaling_group_id
  lb_target_group_arn    = module.load_balancer.target_group_arn
}

# 6. Open TCP Port 80 on Security Group
#esource "aws_security_group_rule" "load_balancer_port" {
#  security_group_id = module.load_balancer.security_group_id
#  type              = "ingress"
#  from_port         = 80
#  to_port           = 80
#  protocol          = "tcp"
#  cidr_blocks       = ["0.0.0.0/0"]
#}

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
        Effect   = "Allow",
        Action   = ["ec2:RebootInstances"],
        Resource = ["*"],
      },
    ],
  })
}

resource "aws_iam_user_policy_attachment" "web_server_user_policy" {
  user       = aws_iam_user.web_server_user.name
  policy_arn = aws_iam_policy.restart_policy.arn
}
