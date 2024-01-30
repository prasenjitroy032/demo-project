# File: load_balancer/variables.tf

variable "subnet_ids" {
  description = "List of subnet IDs where the load balancer will be placed"
  type        = list(string)
}

variable "target_port" {
  description = "Port on which targets receive traffic from the load balancer"
  type        = number
}

variable "listener_port" {
  description = "Port on which the load balancer listens for incoming traffic"
  type        = number
}
