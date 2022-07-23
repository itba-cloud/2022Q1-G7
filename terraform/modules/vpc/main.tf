
#AWS VPC
resource "aws_vpc" "this" {

  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.vpc_tags,
  )
}

################################################################################
# Public subnet
################################################################################
resource "aws_subnet" "public" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = merge(
    {
      "Name" = format(
        "${var.name}-public-%s",
        each.key,
      )
    },
    var.tags,
    each.value.tags
  )
}

################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private" {
  for_each          = var.private_subnets
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
    var.tags,
    each.value.tags
  )
}

resource "aws_network_acl" "this" {
  vpc_id = aws_vpc.this.id

  dynamic "egress" {
    for_each = var.network_acl.egress
    content {
      from_port  = egress.value.from_port
      protocol   = egress.value.protocol
      rule_no    = egress.value.rule_number
      to_port    = egress.value.to_port
      cidr_block = egress.value.cidr_block
      action     = egress.value.rule_action
    }
  }

  dynamic "ingress" {
    for_each = var.network_acl.ingress
    content {
      rule_no    = ingress.value.rule_number
      protocol   = ingress.value.protocol
      action     = ingress.value.rule_action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  tags = merge(
    {
      "Name" = "${var.name}-private"
    },
    var.tags,
    var.network_acl_tags
  )
}

resource "aws_network_acl_association" "private" {
  for_each       = var.private_subnets
  network_acl_id = aws_network_acl.this.id
  subnet_id      = aws_subnet.private[each.key].id
}
