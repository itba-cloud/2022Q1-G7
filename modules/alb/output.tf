output "target_groups" {
  value = aws_lb_target_group.this
}

output "arn" {
  value = aws_lb.this.arn
}

output "listener_arn" {
  value = aws_alb_listener.http.arn
}

output "dns_name" {
  value = aws_lb.this.dns_name
}

output "zone_id" {
  value = aws_lb.this.zone_id
}
