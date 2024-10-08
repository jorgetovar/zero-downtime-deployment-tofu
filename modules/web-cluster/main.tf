resource "aws_launch_template" "zdd" {
  name_prefix   = "zdd-"
  image_id      = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = base64encode(file("${path.module}/user-data.sh"))
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "zdd" {

  name                = "${var.cluster_name}-${aws_launch_template.zdd.name}"
  vpc_zone_identifier = var.subnets
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type   = "ELB"

  min_elb_capacity = var.min_size

  min_size = var.min_size
  max_size = var.max_size

  lifecycle {
    create_before_destroy = true
  }

  # Use instance refresh to roll out changes to the ASG
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  launch_template {
    id      = aws_launch_template.zdd.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}

resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port         = var.server_port
  to_port           = var.server_port
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
}


resource "aws_lb" "zdd" {
  name               = var.cluster_name
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.zdd.arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "asg" {
  name     = var.cluster_name
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}