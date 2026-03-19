output "asg_name" {
  value       = aws_autoscaling_group.app_asg.name
  description = "This is the name of the Auto Scaling Group (ASG) created for EC2 instance"
}