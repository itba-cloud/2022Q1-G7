resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress
    content {
      from_port   = ingress.value.from_port
      protocol    = ingress.value.protocol
      to_port     = ingress.value.to_port
      cidr_blocks = ingress.value.cidr_blocks
    }

  }

  dynamic "egress" {
    for_each = var.sg_egress
    content {

      from_port   = egress.value.from_port
      protocol    = egress.value.protocol
      to_port     = egress.value.to_port
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}
