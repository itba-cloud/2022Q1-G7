# ---------------------------------------------------------------------------
# ECS resources
# ---------------------------------------------------------------------------

resource "aws_ecs_task_definition" "this" {
  for_each = var.services
  family   = "${each.value.name}-task"
  container_definitions = [{
    name = "${each.value.name}-container"
    image = "${each.value.image}"
    essential = true
    portMappings = [{
      containerPort = each.value.containerPort
      hostPort = each.value.hostPort
    }]
  }]
  requires_compatibilities = ["FARGATE"]
  networkMode              = "awsvpc"
  memory                   = var.container_memory
  cpu                      = var.container_cpu
  tags                     = var.task_definition_tags
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
}


resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
  tags = var.cluster_tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_service" "this" {

  for_each = var.services

  depends_on = [
    aws_ecs_cluster.this
  ]

  name    = "${each.value.name}-service"
  cluster = aws_ecs_cluster.this.cluster_arn
  desired_count = each.value.desiredCount
  enable_ecs_managed_tags = true
  launch_type = "FARGATE"
  load_balancer {
    elb_name = var.elb_name
    container_name = "${each.value.name}-container"
    container_port = each.value.port
    # target_group_arn = var.target_group_arn
  }
}
