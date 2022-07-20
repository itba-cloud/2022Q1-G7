# ---------------------------------------------------------------------------
# ECS resources
# ---------------------------------------------------------------------------
resource "aws_ecs_task_definition" "this" {
  for_each = { for idx, service in keys(var.services) :
    idx => var.services[service]
  }

  family = "${each.value.name}-task"
  container_definitions = jsonencode([{
    name      = "${each.value.name}-container"
    image     = "${aws_ecr_repository.this[each.key].repository_url}:latest"
    essential = true

    environment = [
      { "name" : "CLIENT_ID", "value" : var.client_id },
      { "name" : "CLIENT_SECRET", "value" : var.client_secret },
      { "name" : "AUTH_DOMAIN", "value" : var.auth_domain },
      { "name" : "REDIRECT_URI", "value" : var.redirect_uri },
      { "name" : "PRIVATE_KEY", "value" : var.private_key },
    ]

    portMappings = [{
      protocol      = "tcp"
      containerPort = each.value.containerPort
      hostPort      = 80
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.id,
        awslogs-region        = var.logs_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.container_memory
  cpu                      = var.container_cpu
  tags = merge(
    {
      "Name" = "${each.value.name}-task"
    },
    var.tags,
    var.task_definition_tags
  )
  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn
}


resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    {
      "Name" = "${var.name}-cluster"
    },
    var.tags,
    var.cluster_tags
  )
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "fargate"
  retention_in_days = 1
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE"]
}

module "internal_alb" {
  source        = "../lb"
  name          = "${var.name}-internal-alb"
  vpc_id        = var.vpc_id
  vpc_cidr      = var.vpc_cidr
  internal      = true
  target_groups = [for key, service in var.services : { name : service.name, health_check_path : var.health_check_path }]

  subnet_ids = var.private_subnet_ids

  sg_ingress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "icmp"
      cidr_blocks = [var.vpc_cidr]
    },

    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    },

    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  ]

  sg_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.vpc_cidr]
    }
  ]
  tags = {
    security_group_tags = var.private_alb_tags.security_group_tags
    load_balancer_tags  = var.private_alb_tags.load_balancer_tags
    target_group_tags   = var.private_alb_tags.target_group_tags
    listener_tags       = var.private_alb_tags.listener_tags
    common              = var.private_alb_tags.tags

  }
}

module "internal_alb_dns" {

  depends_on = [
    module.internal_alb
  ]

  source = "../route_53"

  vpc_id = var.vpc_id

  hosted_zone_name = "internal.service"
  records = [
    {
      name    = ""
      type    = "A"
      ttl     = 60
      records = []
      alias = {
        name                   = module.internal_alb.dns_name,
        zone_id                = module.internal_alb.zone_id,
        evaluate_target_health = true
      }
    }
  ]
}

resource "aws_ecs_service" "this" {

  for_each = { for idx, service in keys(var.services) :
    idx => var.services[service]
  }

  depends_on = [
    aws_ecs_cluster.this,
    aws_ecs_task_definition.this
  ]

  name            = "${each.value.name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[each.key].arn

  desired_count = each.value.replicas

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  enable_ecs_managed_tags = true

  network_configuration {
    security_groups  = [aws_security_group.this.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.internal_alb.target_groups[each.key].arn
    container_name   = "${each.value.name}-container"
    container_port   = each.value.containerPort
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
