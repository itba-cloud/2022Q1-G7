# ---------------------------------------------------------------------------
# Amazon API Gateway
# ---------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "this" {
  provider = aws.aws
  name     = local.apigateway.name

}

module "courses" {
  source = "../../modules/api_resource"
  providers = {
    aws = aws.aws
  }
  api_id    = aws_api_gateway_rest_api.this.id
  part      = "courses"
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  methods   = local.apigateway.resources["courses"]
}

module "profiles" {
  source = "../../modules/api_resource"
  providers = {
    aws = aws.aws
  }
  api_id    = aws_api_gateway_rest_api.this.id
  part      = "profiles"
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  methods   = local.apigateway.resources["profiles"]
}

module "threads" {
  source = "../../modules/api_resource"
  providers = {
    aws = aws.aws
  }
  api_id    = aws_api_gateway_rest_api.this.id
  part      = "threads"
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  methods   = local.apigateway.resources["threads"]
}

resource "aws_api_gateway_deployment" "this" {
  provider = aws.aws
  depends_on = [
    module.courses,
    module.profiles,
    module.threads
  ]
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.this.body,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  provider = aws.aws

  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "development"
}

# Monitor all API Gateway resources for changes
resource "aws_api_gateway_method_settings" "general_settings" {
  provider = aws.aws
  count    = length(local.apigateway.logging_levels)

  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = local.apigateway.logging_levels[count.index]

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}

# resource "aws_cloudwatch_log_group" "" {
#   name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.example.id}/${var.stage_name}"
#   retention_in_days = 7
# }
