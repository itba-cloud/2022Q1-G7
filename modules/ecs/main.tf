# ---------------------------------------------------------------------------
# ECS resources
# ---------------------------------------------------------------------------

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

  tags = merge(
    {
      "Name" = "${var.name}-sg-service"
    },
    var.tags,
    var.security_group_tags
  )

}



# resource "aws_ecs_task_definition" "this" {
#   count = length(var.services)

#   depends_on = [
#     docker_registry_image.this
#   ]

#   family = "${var.services[count.index].name}-task"
#   container_definitions = jsonencode([{
#     name  = "${var.services[count.index].name}-container"
#     image = "${aws_ecr_repository.this.repository_url}/${element(var.services, count.index).image}"
#     #image     = "${var.services[count.index].image}"
#     essential = true
#     portMappings = [{
#       containerPort = var.services[count.index].containerPort
#       hostPort      = 80
#     }]
#   }])
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   memory                   = var.container_memory
#   cpu                      = var.container_cpu
#   tags = merge(
#     {
#       "Name" = "${var.services[count.index].name}-task"
#     },
#     var.tags,
#     var.task_definition_tags
#   )
#   task_role_arn      = var.task_role_arn
#   execution_role_arn = var.execution_role_arn
# }


resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"
  tags = merge(
    {
      "Name" = "${var.name}-cluster"
    },
    var.tags,
    var.cluster_tags
  )
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE"]
}

module "services_alb" {
  source        = "../alb"
  name          = "${var.name}-alb"
  vpc_id        = var.vpc_id
  internal      = false
  target_groups = [for service in var.services : "${service.name}-service"]

  subnet_ids = var.subnet_ids

  security_group_tags = var.alb_tags.security_group_tags
  load_balancer_tags = var.alb_tags.load_balancer_tags
  target_group_tags = var.alb_tags.target_group_tags
  listener_tags = var.alb_tags.listener_tags
  tags = var.alb_tags.tags
}

# resource "aws_ecs_service" "this" {

#   count = length(var.services)

#   depends_on = [
#     aws_ecs_cluster.this
#   ]

#   name            = "${var.services[count.index].name}-service"
#   cluster         = aws_ecs_cluster.this.id
#   task_definition = aws_ecs_task_definition.this[count.index].arn

#   desired_count = var.services[count.index].replicas

#   deployment_minimum_healthy_percent = 50
#   deployment_maximum_percent         = 200

#   launch_type         = "FARGATE"
#   scheduling_strategy = "REPLICA"

#   enable_ecs_managed_tags = true

#   network_configuration {
#     security_groups  = [aws_security_group.service.id]
#     subnets          = var.subnet_ids
#     assign_public_ip = false
#   }

#   load_balancer {
#     target_group_arn = module.services_alb.target_groups[count.index].arn
#     container_name   = "${var.services[count.index].name}-container"
#     container_port   = var.services[count.index].containerPort
#   }

#   lifecycle {
#     ignore_changes = [task_definition, desired_count]
#   }
# }


