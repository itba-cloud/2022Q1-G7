# ---------------------------------------------------------------------------
# Amazon API Gateway
# ---------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "this" {
  provider = aws.aws
  name     = local.apigateway.name

}

module "courses" {
  source = "../../modules/api_resource_4.0"
  providers = {
    aws = aws.aws
  }
  api_id    = aws_api_gateway_rest_api.this.id
  part      = "courses"
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  methods   = local.apigateway.resources["courses"]
}

module "courses_by_id" {
  source = "../../modules/api_resource_4.0"
  providers = {
    aws = aws.aws
  }
  api_id    = aws_api_gateway_rest_api.this.id
  part      = "{courseId}"
  parent_id = module.courses.id
  methods   = local.apigateway.resources["courses_by_id"]
}

module "profiles" {
  source = "../../modules/api_resource_4.0"
  providers = {
    aws = aws.aws
  }
  api_id    = aws_api_gateway_rest_api.this.id
  part      = "profiles"
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  methods   = local.apigateway.resources["profiles"]
}

module "threads" {
  source = "../../modules/api_resource_4.0"
  providers = {
    aws = aws.aws
  }
  api_id    = aws_api_gateway_rest_api.this.id
  part      = "threads"
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  methods   = local.apigateway.resources["threads"]
}


# resource "aws_api_gateway_deployment" "this" {
#   provider = aws.aws

#   rest_api_id = aws_api_gateway_rest_api.this.id

#   triggers = {
#     redeployment = sha1(jsonencode([
#       # aws_api_gateway_rest_api.this.body,
#       aws_api_gateway_resource.this.id,
#       aws_api_gateway_method.this.id,
#       aws_api_gateway_integration.this.id,
#     ]))
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_api_gateway_stage" "this" {
#   provider = aws.aws

#   deployment_id = aws_api_gateway_deployment.this.id
#   rest_api_id   = aws_api_gateway_rest_api.this.id
#   stage_name    = "production"
# }
