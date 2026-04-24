resource "aws_lb" "app" {
  name               = "aws-tools-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]

  tags = {
    Name = "aws-tools-alb"
  }
}

# ----------------------------
# Target Group: Streamlit app (8501)
# ----------------------------
resource "aws_lb_target_group" "app" {
  name     = "aws-tools-tg"
  port     = 8501
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }
}

# ----------------------------
# Target Group: Apache (80)
# ----------------------------
resource "aws_lb_target_group" "apache" {
  name     = "aws-tools-apache-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/ip.php"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }
}

# ----------------------------
# ALB Listener (default → Streamlit)
# ----------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ----------------------------
# Rule: /ip.php → Apache
# ----------------------------
resource "aws_lb_listener_rule" "apache_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apache.arn
  }

  condition {
    path_pattern {
      values = ["/ip.php"]
    }
  }

  depends_on = [aws_lb_listener.http]
}
