# File: vpc/variables.tf

variable "cidr" {
  description = "CIDR block for the VPC"
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
}
