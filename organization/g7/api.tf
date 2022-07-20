resource "aws_apigatewayv2_vpc_link" "this" {
  provider = aws.aws
  name               = "vpc-link2"
  security_group_ids = [module.ecs.security_group_id]
  subnet_ids         = [for az, subnet in module.vpc["vpc-1"].private_subnet_ids : subnet]
}

module "api_gw" {
  source = "../../modules/api_gw"

  providers = {
    aws = aws.aws
  }

  depends_on = [
    aws_apigatewayv2_vpc_link.this
  ]

  name          = "ecs-http-api"
  protocol_type = "HTTP"

  integrations = [
    {
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"
      connection_type    = "VPC_LINK"
      connection_id      = aws_apigatewayv2_vpc_link.this.id
      request_parameters = {
        "overwrite:path" = "$request.path"
      }
      integration_uri = module.ecs.alb_listener_arn
    }
  ]
  routes = [
    {
      route_key          = "ANY /{proxy+}",
      authorization_type = "CUSTOM"
    }
  ]
  authorizers = [
    {
      authorizer_type                   = "REQUEST",
      authorizer_uri                    = aws_lambda_function.this["auth"].invoke_arn,
      identity_sources                  = ["$request.header.Authorization"]
      name                              = local.authorizer_name
      authorizer_payload_format_version = "2.0"
    }
  ]

  stages = [
    {
      name        = "production",
      auto_deploy = false
    }
  ]

}
