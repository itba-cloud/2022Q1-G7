output "invoke_arn" {
    description = "The ARN of the lambda function to invoke"
    value       = aws_lambda_function.this.invoke_arn
}
  