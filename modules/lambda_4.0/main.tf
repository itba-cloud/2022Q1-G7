# ---------------------------------------------------------------------------
# AWS Lambda resources
# ---------------------------------------------------------------------------
# Lambda
resource "aws_lambda_function" "this" {

  filename      =  "../../resources/${var.path}"
  function_name =  var.name
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "lambda_handler.main"
  runtime       = "python3.9"
}


resource "aws_lambda_permission" "apigw_lambda" {

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "${var.principal}.amazonaws.com"

  #source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/${aws_api_gateway_method.this.http_method}${aws_api_gateway_resource.this.path}"
}