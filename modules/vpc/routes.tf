resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(values(var.public_subnets))
  subnet_id      = element(values(aws_subnet.public), count.index).id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  count = length(values(var.private_subnets))
  vpc_id = aws_vpc.this.id
}
resource "aws_route" "private" {
  count = length(values(var.private_subnets))
  route_table_id         = element(aws_route_table.private,count.index).id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.main,count.index).id
}
resource "aws_route_table_association" "private" {
  count          = length(values(var.private_subnets))
  subnet_id      = element(values(aws_subnet.private), count.index).id
  route_table_id = element(aws_route_table.private,count.index).id
}