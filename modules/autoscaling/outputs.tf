# File: autoscaling/outputs.tf

output "autoscaling_group_id" {
  value = aws_autoscaling_group.main.id
}
