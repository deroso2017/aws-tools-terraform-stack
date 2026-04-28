resource "aws_launch_template" "app-lt" {
  name_prefix   = "app-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t3.small"
  key_name      = var.key_pair

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app.id]
  }

  user_data = base64encode(templatefile("${path.module}/scripts/user_data_capstone.sh", {
    rds_endpoint      = aws_db_instance.postgres.endpoint
    db_name           = var.db_name
    db_username       = var.db_username
    db_password       = var.db_password
    supabase_url      = var.supabase_url
    supabase_amon_key = var.supabase_amon_key
    aws_session_key   = var.aws_session_key
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "aws-tools-app-asg"
    }
  }
}

resource "aws_autoscaling_group" "app-asg" {
  name                = "app-asg"
  min_size            = 1
  max_size            = 4
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.public.id, aws_subnet.public_2.id]
  target_group_arns = [
    aws_lb_target_group.app.arn,
    aws_lb_target_group.apache.arn
  ]

  launch_template {
    id      = aws_launch_template.app-lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app-tf-asg"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_policy" "app-tf-cpu-policy" {
  name                   = "app-tf-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.app-asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}
