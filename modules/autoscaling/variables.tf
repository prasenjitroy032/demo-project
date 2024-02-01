# File: autoscaling/variables.tf
variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling group"
  type        = number
}

variable "private_subnet_ids" {
  description = "List of public subnet IDs for auto scaling group instances"
  type        = list(string)
}

variable "key_name" {
  description = "key name to use"
  type        = string
}

variable "lb_tg_arn" {
  description = "ARN of the target group associated with the load balancer"
  type        = string
}

variable "lb_sg" {
  description = "ID of the security group associated with the load balancer"
  type        = string
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}



# Add other variables as needed
