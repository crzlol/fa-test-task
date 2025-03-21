resource "aws_security_group" "alb" {
  name   = "fa-${var.env}-eks"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "eks" {
  name            = "fa-${var.env}-eks"
  internal        = false
  security_groups = [aws_security_group.alb.id]
  subnets         = data.aws_subnets.default.ids
}

resource "aws_alb_listener" "eks_80" {
  load_balancer_arn = aws_alb.eks.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is FA-TEST-TASK internal ALB response"
      status_code  = "200"
    }
  }
}

resource "aws_alb_target_group" "nginx" {
  name_prefix = "nginx"
  port        = data.kubernetes_service.nginx.spec[0].port[0]["node_port"]
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path = "/"
  }

  depends_on = [helm_release.nginx]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "nginx" {
  autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names[0]
  lb_target_group_arn    = aws_alb_target_group.nginx.arn
}

resource "aws_alb_listener_rule" "nginx" {
  listener_arn = aws_alb_listener.eks_80.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.nginx.arn
  }
  condition {
    host_header {
      values = [aws_alb.eks.dns_name]
    }
  }
  tags = {
    name = "nginx"
  }
}

resource "aws_security_group_rule" "allow_alb_to_eks" {
  type      = "ingress"
  protocol  = "tcp"
  from_port = aws_alb_target_group.nginx.port
  to_port   = aws_alb_target_group.nginx.port

  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = aws_security_group.alb.id
}
