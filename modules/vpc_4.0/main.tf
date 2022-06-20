
#AWS VPC
resource "aws_vpc" "this" {

  cidr_block = var.cidr

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.vpc_tags,
  )
}


################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    {
      "Name" = format(
        "${var.name}-private-%s",
        each.key,
      )
    },

  )
}
