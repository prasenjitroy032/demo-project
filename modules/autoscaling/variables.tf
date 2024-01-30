# File: autoscaling/variables.tf

variable "vpc_id" {
  description = "ID of the VPC where auto scaling group will be created"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for auto scaling group instances"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the EC2 key pair to associate with instances"
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling group"
  type        = number
  default     = 2 # Default value for desired_capacity
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling group"
  type        = number
}

variable "scaling_adjustment" {
  description = "Number of instances by which to scale out when a scaling activity is triggered"
  type        = number
  default     = 1 # Default value for scaling_adjustment
}

variable "cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another can start"
  type        = number
  default     = 300 # Default value for cooldown (5 minutes)
}

variable "estimated_instance_warmup" {
  description = "The estimated time, in seconds, until a newly launched instance can contribute to the CloudWatch metrics"
  type        = number
  default     = 300 # Default value for estimated_instance_warmup (5 minutes)
}

# Add more variables as needed
