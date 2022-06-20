# ---------------------------------------------------------------------------
# AWS api resources
# ---------------------------------------------------------------------------
# api resources
resource "aws_api_gateway_resource" "this" {
  path_part   = var.part
  parent_id   = var.parent_id
  rest_api_id = var.api_id
}

resource "aws_api_gateway_method" "this" {
  # TODO: change to count
  for_each = var.methods

  rest_api_id   = var.api_id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = each.key
  authorization = "NONE"
  request_parameters = try(each.value.request_parameters, {})
  #request_parameters = each.value.request_parameters ? each.value.request_parameters : {}
}

resource "aws_api_gateway_integration" "this" {
  # TODO: change to count
  for_each = var.methods

  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this[each.key].http_method
  integration_http_method = each.key
  type                    = each.value.type
  uri                     = each.value.uri
}
