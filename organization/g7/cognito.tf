resource "aws_cognito_user_pool" "this" {
  provider = aws.aws
  name     = "users"
}
