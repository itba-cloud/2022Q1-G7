# --------------------------------------------------------------------
# ECS output
# --------------------------------------------------------------------
output "security_group_id" {
  value = aws_security_group.this.id
}

output "alb_id" {
  value = module.internal_alb.alb_id
}

output "alb_arn" {
  value = module.internal_alb.arn
}

output "alb_listener_arn" {
  value = module.internal_alb.listener_arn
}

