output "target_groups" {
  value       = aws_lb_target_group.this
  description = "Target Groups"
}

output "alb_id" {
  value       = aws_lb.this.id
  description = "Load Balancer Id"
}
output "arn" {
  value       = aws_lb.this.arn
  description = "Load Balancer Arn"
}

output "listener_arn" {
  value       = aws_alb_listener.http.arn
  description = "Listener Arn"
}

output "dns_name" {
  value       = aws_lb.this.dns_name
  description = "Load Balancer DNS Name"
}

output "zone_id" {
  value       = aws_lb.this.zone_id
  description = "Load Balancer Zone Id"
}
