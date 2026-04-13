output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_dns" {
  value = aws_lb.app.dns_name
}

output "launch_template_id" {
  value = aws_launch_template.app-lt.id
}

output "asg_name" {
  value = aws_autoscaling_group.app-asg.name
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_connection_string" {
  value     = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.endpoint}/${var.db_name}"
  sensitive = true
}
