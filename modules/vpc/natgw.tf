# resource "aws_nat_gateway" "main" {
#   count         = length(values(var.private_subnets))
#   allocation_id = element(aws_eip.nat, count.index).id
#   subnet_id     = element(values(aws_subnet.public), count.index).id
#   depends_on    = [aws_internet_gateway.this]
#   tags = merge(
#     {
#       Name = "${var.name}-${count.index}"
#     },
#     var.tags,
#     var.nat_gateway_tags
#   )
# }
 
# resource "aws_eip" "nat" {
#   count = length(values(var.private_subnets))
#   vpc = true
# }