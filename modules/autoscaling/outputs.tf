# File: autoscaling/outputs.tf

output "launch_template_id" {
  value = aws_launch_template.main.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.main.name
}

# Add other outputs as needed

