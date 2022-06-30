# resource "aws_dynamodb_table" "this" {
#   provider = aws.aws
#   for_each = local.dynambodb
#   name     = each.key
#   hash_key = each.value.key

#   dynamic "attribute" {
#     for_each = each.value.attributes
#     content {
#       name = attribute.value.name
#       type = attribute.value.type
#     }
#   }

#   read_capacity  = each.value.read_capacity
#   write_capacity = each.value.write_capacity
#   dynamic "global_secondary_index" {
#     for_each = [for attr in each.value.attributes : attr if attr.name != each.value.key]
#     content {
#       name               = global_secondary_index.value.name
#       hash_key           = global_secondary_index.value.name
#       projection_type    = "INCLUDE"
#       write_capacity     = 1
#       read_capacity      = 1
#       non_key_attributes = [each.value.key]
#     }
#   }

# }
