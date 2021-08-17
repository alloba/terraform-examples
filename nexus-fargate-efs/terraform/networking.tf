resource "aws_lb_target_group" "nexus-lb-targetgroup" {
  name_prefix = "nexus"
  port        = 8081
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc-host.id

  health_check {
    enabled = true
    path    = "/"
    timeout = 120
    interval = 200
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  depends_on = [aws_alb.nexus-lb]
  tags = merge(local.common_tags, {})
}

resource "aws_alb" "nexus-lb" {
  name               = "nexus-lb"
  internal           = false
  load_balancer_type = "application"

  subnets = [data.aws_subnet.public-west-a.id, data.aws_subnet.public-west-b.id, data.aws_subnet.public-west-c.id]

  security_groups = [
    aws_security_group.lb-nexus.id
  ]

  tags = merge(local.common_tags, {})
}

resource "aws_alb_listener" "nexus-lb-listener" {
  load_balancer_arn = aws_alb.nexus-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexus-lb-targetgroup.arn
  }
}

resource "aws_route53_record" "nexus-endpoint" {
  name = "nexus2.${data.aws_route53_zone.hosted-zone.name}"
  type = "A"
  zone_id = data.aws_route53_zone.hosted-zone.id

  alias {
    evaluate_target_health = false
    name = aws_alb.nexus-lb.dns_name
    zone_id = aws_alb.nexus-lb.zone_id
  }
}