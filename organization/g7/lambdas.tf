# # ---------------------------------------------------------------------------
# # AWS Lambda resources
# # ---------------------------------------------------------------------------
# # Lambda
# resource "aws_lambda_function" "this" {
#   provider      = aws.aws
#   for_each      = local.lambdas
#   filename      = "../../resources/${each.value.path}"
#   function_name = each.key
#   role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
#   handler       = "${each.value.handler}.main"
#   runtime       = "python3.9"
# }

# resource "aws_lambda_permission" "apigw_lambda" {
#   provider      = aws.aws
#   for_each      = local.lambdas
#   action        = "lambda:InvokeFunction"
#   function_name = each.key

#   principal  = "${each.value.principal}.amazonaws.com"
#   source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/${each.value.method}/${each.value.resource}"
#   #source_arn = "${aws_api_gateway_stage.this.execution_arn}/${each.value.method}/${each.value.resource}"
#   #source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}"

#   #source_arn = "arn:aws:execute-api:*:*:*"
# }
