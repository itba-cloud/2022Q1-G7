resource "aws_route53_zone" "this" {
  name = var.hosted_zone_name
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "this" {
  depends_on = [
    aws_route53_zone.this
  ]

  count = length(var.records)

  zone_id = aws_route53_zone.this.zone_id
  name    = var.records[count.index].name
  type    = var.records[count.index].type
  ttl     = length(var.records[count.index].records) > 1 ? var.records[count.index].ttl : null

  records = length(var.records[count.index].records) > 1 ? var.records[count.index].records : null

  alias {
    name                   = var.records[count.index].alias.name
    zone_id                = var.records[count.index].alias.zone_id
    evaluate_target_health = var.records[count.index].alias.evaluate_target_health
  }
}
