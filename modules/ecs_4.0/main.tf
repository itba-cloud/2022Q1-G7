# ---------------------------------------------------------------------------
# ECS resources
# ---------------------------------------------------------------------------

resource "aws_security_group" "alb" {
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
}

resource "aws_security_group" "service" {
  name = "${var.name}-sg-service"
  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}

resource "aws_ecs_task_definition" "this" {
  count = length(var.services)

  family = "${var.services[count.index].name}-task"
  container_definitions = jsonencode([{
    name      = "${var.services[count.index].name}-container"
    image     = "${var.services[count.index].image}"
    essential = true
    portMappings = [{
      containerPort = var.services[count.index].containerPort
      hostPort      = 80
    }]
  }])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.container_memory
  cpu                      = var.container_cpu
  tags                     = var.task_definition_tags
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
}


resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"
  tags = var.cluster_tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_service" "this" {

  count = length(var.services)

  depends_on = [
    aws_ecs_cluster.this
  ]

  name            = "${var.services[count.index].name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[count.index].arn

  desired_count = var.services[count.index].replicas

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  enable_ecs_managed_tags = true

  network_configuration {
    security_groups  = [aws_security_group.service.id]
    subnets          = var.subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.this[count.index].arn
    container_name   = "${var.services[count.index].name}-container"
    container_port   = var.services[count.index].containerPort
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_lb" "this" {
  name = "${var.name}-nlb"

  internal = false

  load_balancer_type = "network"

  subnets = var.subnet_ids

  enable_deletion_protection = false

}

resource "aws_alb_target_group" "this" {

  count = length(var.services)

  name        = "${var.services[count.index].name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/ping"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  count = length(var.services)

  load_balancer_arn = aws_lb.this.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.this[count.index].id
    type             = "forward"
  }
}
