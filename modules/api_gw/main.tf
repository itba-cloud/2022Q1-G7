resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = var.protocol_type
}


resource "aws_apigatewayv2_integration" "this" {
  count            = length(var.integrations)
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = var.integrations[count.index].integration_type

  integration_method = var.integrations[count.index].integration_method
  integration_uri    = var.integrations[count.index].integration_uri

  connection_type = var.integrations[count.index].connection_type
  connection_id   = var.integrations[count.index].connection_id

  #map stage path to root path
  request_parameters = var.integrations[count.index].request_parameters

}

resource "aws_apigatewayv2_route" "this" {

  depends_on = [
    aws_apigatewayv2_authorizer.this
  ]

  count = length(var.routes)

  api_id    = aws_apigatewayv2_api.this.id
  route_key = var.routes[count.index].route_key

  target = "integrations/${aws_apigatewayv2_integration.this[count.index].id}"

  authorization_type = var.routes[count.index].authorization_type
  authorizer_id      = aws_apigatewayv2_authorizer.this[count.index].id
}


resource "aws_apigatewayv2_deployment" "this" {
  depends_on = [
    aws_apigatewayv2_route.this
  ]
  api_id = aws_apigatewayv2_api.this.id
}



resource "aws_apigatewayv2_stage" "this" {
  count         = length(var.stages)
  api_id        = aws_apigatewayv2_api.this.id
  deployment_id = aws_apigatewayv2_deployment.this.id
  name          = var.stages[count.index].name
  auto_deploy   = var.stages[count.index].auto_deploy

}

resource "aws_apigatewayv2_authorizer" "this" {

  count = length(var.authorizers)

  depends_on = [
    aws_apigatewayv2_api.this
  ]

  api_id                           = aws_apigatewayv2_api.this.id
  authorizer_type                  = var.authorizers[count.index].authorizer_type
  authorizer_uri                   = var.authorizers[count.index].authorizer_uri
  authorizer_result_ttl_in_seconds = 0

  #identity_sources                  = var.authorizers[count.index].identity_sources
  name                              = var.authorizers[count.index].name
  authorizer_payload_format_version = var.authorizers[count.index].authorizer_payload_format_version
  authorizer_credentials_arn        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  enable_simple_responses           = true
}

resource "aws_lambda_permission" "this" {
  count = length(var.authorizers)

  action        = "lambda:InvokeFunction"
  function_name = "auth"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.this.id}/authorizers/${aws_apigatewayv2_authorizer.this[count.index].id}"
}
