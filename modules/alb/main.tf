resource "aws_security_group" "this" {
  name   = "${var.name}-sg-alb"
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0", ]
  }

  egress {
    protocol         = -1
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    {
      "Name" = "${var.name}-sg-alb"
    },
    var.tags,
    var.security_group_tags
  )
}


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
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
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
