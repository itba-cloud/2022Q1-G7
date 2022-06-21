output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC Id"
}

output "subnet_ids" {
  value       = { for az, subnet in aws_subnet.private : az => subnet.id }
  description = "Subnet Ids"
}

output "network_acl_id" {
  value       = aws_network_acl.this.id
  description = "Network ACL Id"
}
