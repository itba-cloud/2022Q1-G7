resource "aws_apigatewayv2_api" "this" {
  name          = "ecs-http-api"
  protocol_type = "HTTP"
}

##http
resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "vpc-link2"
  security_group_ids = [aws_security_group.this.id]
  subnet_ids         = var.private_subnet_ids

}


resource "aws_apigatewayv2_integration" "this" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "HTTP_PROXY"

  integration_method = "ANY"
  integration_uri    = module.internal_alb.listener_arn

  connection_type = "VPC_LINK"
  connection_id   = aws_apigatewayv2_vpc_link.this.id

  #map stage path to root path
  request_parameters = {
    "overwrite:path" = "$request.path"

  }

}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.this.id}"
}


# resource "aws_api_gateway_resource" "this" {
#   path_part   = "{proxy+}"
#   parent_id   = aws_apigatewayv2_api.this.root_resource_id
#   rest_api_id = aws_apigatewayv2_api.this.id
# }

# resource "aws_api_gateway_method" "this" {

#   rest_api_id   = aws_api_gateway_rest_api.this.id
#   resource_id   = aws_api_gateway_resource.this.id
#   http_method   = "ANY"
#   authorization = "NONE"

#   #?request_parameters = try(each.value.request_parameters, {})
#   #request_parameters = each.value.request_parameters ? each.value.request_parameters : {}
# }

# resource "aws_api_gateway_integration" "this" {
#   rest_api_id   = aws_api_gateway_rest_api.this.id
#   resource_id   = aws_api_gateway_resource.this.id
#   http_method             = "ANY"
#   integration_http_method = "GET"
#   type                    = "HTTP_PROXY"
#   uri                     = module.internal_alb.arn
#   connection_type = "VPC_LINK"
#   connection_id   = aws_apigatewayv2_vpc_link.this.id
# }


#rest
# resource "aws_api_gateway_vpc_link" "this" {
#   name        = "vpc-link"
#   target_arns = [module.internal_alb.arn]
# }

resource "aws_apigatewayv2_deployment" "this" {
  depends_on = [
    aws_apigatewayv2_route.this
  ]
  api_id = aws_apigatewayv2_api.this.id



}



resource "aws_apigatewayv2_stage" "this" {
  api_id        = aws_apigatewayv2_api.this.id
  deployment_id = aws_apigatewayv2_deployment.this.id
  name          = "production"
  auto_deploy   = false

  # access_log_settings {
  #   destination_arn = "${aws_cloudwatch_log_group.this.arn}"
  #   format          = "text/plain"
  # }


  #   default_route_settings {
  #     data_trace_enabled       = true
  #     detailed_metrics_enabled = true
  #     logging_level            = "ERROR"
  #     throttling_rate_limit    = 100
  #     throttling_burst_limit   = 50
  #   }

}
