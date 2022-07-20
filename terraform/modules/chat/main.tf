#reference https://docs.aws.amazon.com/apigateway/latest/developerguide/websocket-api-chat-app.html#websocket-api-chat-app-create-dependencies

locals {
  lambdas = {
    "connect" = {
      resource  = "../../../resources/lambda/connect_handler.js.zip"
      route_key = "$connect"
      handler   = "connect_handler.handler"
    }
    "disconnect" = {
      resource  = "../../../resources/lambda/disconnect_handler.js.zip"
      route_key = "$disconnect"
      handler   = "disconnect_handler.handler"

    }
    "sendmessage" = {
      resource  = "../../resources/../lambda/send_message_handler.js.zip"
      route_key = "sendmessage"
      handler   = "send_message_handler.handler"
    }
    "default" = {
      resource  = "../../resources/../lambda/default_chat_handler.js.zip"
      route_key = "$default"
      handler   = "default_chat_handler.handler"
    }

  }
}

#dynamo table
resource "aws_dynamodb_table" "this" {
  name     = "dynamo-chat"
  hash_key = "connectionId"
  attribute {

    name = "connectionId"
    type = "S"

  }

  read_capacity  = 5
  write_capacity = 5

}
# web socket api
resource "aws_apigatewayv2_api" "this" {
  name                       = "chat-websocket-api"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}



#lambdas
resource "aws_lambda_function" "this" {
  for_each         = local.lambdas
  filename         = each.value.resource
  function_name    = each.key
  role             = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler          = each.value.handler
  runtime          = "nodejs14.x"
  source_code_hash = filebase64sha256(each.value.resource)
}

resource "aws_lambda_permission" "this" {
  for_each      = local.lambdas
  action        = "lambda:InvokeFunction"
  function_name = each.key

  principal  = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_stage.this.execution_arn}/${each.value.route_key}"
  #source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.this.id}/production"
}





# resource "aws_cloudformation_stack" "this" {
#   name = "chat-stack"
# }


# resource "aws_apigatewayv2_authorizer" "this" {
#   for_each = local.lambdas
#   api_id           = aws_apigatewayv2_api.this.id
#   authorizer_type  = "REQUEST"
#   authorizer_uri   = aws_lambda_function.this[each.key].invoke_arn
#   name             = "${each.key}-authorizer"
# }

resource "aws_apigatewayv2_integration" "this" {
  for_each         = local.lambdas
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  #credentials_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.this[each.key].invoke_arn
}


resource "aws_apigatewayv2_route" "this" {
  for_each  = local.lambdas
  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value.route_key
  # api_key_required = false
  # authorization_type = "NONE"
  target = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
  //authorizer_id = aws_apigatewayv2_authorizer.this[each.key].id

}

# resource "aws_apigatewayv2_route_response" "this" {
#   for_each  = local.lambdas
#   api_id             = aws_apigatewayv2_api.this.id
#   route_id           = aws_apigatewayv2_route.this[each.key].id
#   route_response_key = "$default"
# }


resource "aws_apigatewayv2_deployment" "this" {
  depends_on = [
    aws_apigatewayv2_route.this
  ]
  api_id = aws_apigatewayv2_api.this.id



}

resource "aws_cloudwatch_log_group" "this" {
  name = "chat-logs"
}


resource "aws_apigatewayv2_stage" "this" {
  api_id        = aws_apigatewayv2_api.this.id
  deployment_id = aws_apigatewayv2_deployment.this.id
  name          = "production"

  # access_log_settings {
  #   destination_arn = "${aws_cloudwatch_log_group.this.arn}"
  #   format          = "text/plain"
  # }


  default_route_settings {
    data_trace_enabled       = true
    detailed_metrics_enabled = true
    logging_level            = "ERROR"
    throttling_rate_limit    = 100
    throttling_burst_limit   = 50
  }

}
