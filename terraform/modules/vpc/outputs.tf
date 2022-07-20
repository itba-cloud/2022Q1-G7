output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC Id"
}

output "vpc_cidr" {
  value       = aws_vpc.this.cidr_block
  description = "VPC CIDR"
}

output "public_subnet_ids" {
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
  description = "Public Subnet Ids"
}

output "private_subnet_ids" {
  value       = { for az, subnet in aws_subnet.private : az => subnet.id }
  description = "Private Subnet Ids"
}

output "network_acl_id" {
  value       = aws_network_acl.this.id
  description = "Network ACL Id"
}
