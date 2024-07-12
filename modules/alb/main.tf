resource "aws_lb" "alb" {
  name               = "${var.env}-${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets = [
    var.subnet_1a_id,
    var.subnet_1b_id
  ]

  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.alb_logs.bucket
  }

  enable_deletion_protection = false
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.env}-${var.name_prefix}-alb-logs"
  force_destroy = true
}

data "aws_iam_policy_document" "alb_logs_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }
}


resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.alb_logs_policy_document.json
}

resource "aws_lb_target_group" "this" {
  name        = "${var.env}-${var.name_prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id


  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = false
  }

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

}



resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}



