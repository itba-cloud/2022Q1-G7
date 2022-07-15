resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this.id]
  subnets            = var.subnet_ids
  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
    var.load_balancer_tags
  )
}

resource "aws_lb_target_group" "this" {
  count = length(var.target_groups)

  name        = "${element(var.target_groups, count.index)}-${var.internal ? "private" : "public"}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id


  health_check {
    healthy_threshold   = "3"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/${element(var.target_groups, count.index)}"
    unhealthy_threshold = "2"
  }

  tags = merge(
    {
      "Name" = "${element(var.target_groups, count.index)}-${var.internal ? "private" : "public"}-tg"
    },
    var.tags,
    var.target_group_tags
  )
}

resource "aws_alb_listener" "http" {

  count = length(aws_lb_target_group.this.*)

  load_balancer_arn = aws_lb.this.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = element(aws_lb_target_group.this.*, count.index).id
    type             = "forward"
  }

  tags = merge(
    {
      "Name" = "${element(aws_lb_target_group.this.*, count.index).name}"
    },
    var.tags,
    var.listener_tags
  )

}
