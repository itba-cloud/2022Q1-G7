output "target_groups" {
  value = aws_lb_target_group.this
}

output "arn" {
  value = aws_lb.this.arn
}

output "listener_arn" {
  value = aws_alb_listener.http.arn
}
