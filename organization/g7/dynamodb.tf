resource "aws_dynamodb_table" "this" {
  provider  = aws.aws
  for_each  = local.dynambodb
  name      = each.key
  hash_key  = each.value.key
  range_key = lookup(each.value, "range_key", "")

  dynamic "attribute" {
    for_each = each.value.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  read_capacity  = each.value.read_capacity
  write_capacity = each.value.write_capacity

}
