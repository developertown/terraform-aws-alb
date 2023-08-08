locals {
  enabled = var.enabled

  name = "${var.name}-${var.environment}%{if var.suffix != ""}-${var.suffix}%{endif}-alb"
}

module "access_logs" {
  source  = "cloudposse/lb-s3-bucket/aws"
  version = "0.19.0"

  enabled = local.enabled && var.access_logs_enabled && var.access_logs_s3_bucket_id == null

  force_destroy = var.alb_access_logs_s3_bucket_force_destroy

  lifecycle_configuration_rules = var.lifecycle_configuration_rules
}

resource "aws_security_group" "alb" {
  name        = "${local.name}-sg"
  description = "Allow ALB inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow ALB inbound traffic on port 80"
    protocol    = "tcp"
    from_port   = var.http_port
    to_port     = var.http_port
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  }

  ingress {
    description = "Allow ALB inbound traffic on port 443"
    protocol    = "tcp"
    from_port   = var.https_port
    to_port     = var.https_port
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  }

  egress {
    description = "Allow outbound traffic from ALB to internet"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  }
}

resource "aws_lb" "alb" {
  count = local.enabled ? 1 : 0

  name                       = local.name
  internal                   = false #tfsec:ignore:aws-elb-alb-not-public
  load_balancer_type         = "application"
  security_groups            = [one(aws_security_group.alb[*].id)]
  subnets                    = var.subnet_ids
  drop_invalid_header_fields = true

  access_logs {
    bucket  = try(element(compact([var.access_logs_s3_bucket_id, module.access_logs.bucket_id]), 0), "")
    prefix  = var.access_logs_prefix
    enabled = var.access_logs_enabled
  }
}

resource "aws_alb_target_group" "alb" {
  count = local.enabled ? 1 : 0

  name        = "${local.name}-tg"
  port        = var.http_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold = "3"
    interval          = "30"
    protocol          = "HTTP"
    matcher           = "200"
    timeout           = "5"
    path              = var.health_check_path
  }
}

resource "aws_alb_listener" "http" {
  count = local.enabled ? 1 : 0

  load_balancer_arn = one(aws_lb.alb[*].id)
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = var.https_port
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  count = local.enabled && var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = one(aws_lb.alb[*].id)
  port              = var.https_port
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = var.certificate_arn

  default_action {
    target_group_arn = one(aws_alb_target_group.alb[*].id)
    type             = "forward"
  }
}

resource "aws_alb_listener_certificate" "alternate" {
  count = local.enabled && var.certificate_arn != "" ? 1 : 0

  listener_arn    = one(aws_alb_listener.https[*].arn)
  certificate_arn = var.certificate_arn
}

resource "aws_route53_record" "alb" {
  count = local.enabled && var.dns_zone_id != "" ? 1 : 0

  zone_id = var.dns_zone_id
  name    = var.dns_record_name
  type    = "A"

  alias {
    name                   = one(aws_lb.alb[*].dns_name)
    zone_id                = one(aws_lb.alb[*].zone_id)
    evaluate_target_health = false
  }
}

module "metric_alarm" {
  count = local.enabled && var.sns_alarm_topic_arn != "" ? 1 : 0

  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 4.2.0"

  alarm_name          = "ELB - Unhealthy Host Check"
  alarm_description   = "Host is Unhealthy"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.alarm_unheathly_threshold
  period              = 60
  unit                = "Count"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Average"

  dimensions = {
    LoadBalancer = one(aws_lb.alb[*].arn_suffix),
    TargetGroup  = one(aws_alb_target_group.alb[*].arn_suffix)
  }

  alarm_actions = [var.sns_alarm_topic_arn]

  depends_on = [aws_lb.alb, aws_alb_target_group.alb]
}
