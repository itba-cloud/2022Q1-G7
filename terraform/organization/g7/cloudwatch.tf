# ---------------------------------------------------------------------------
# Amazon CloudWatch
# ---------------------------------------------------------------------------

resource "aws_api_gateway_account" "this" {
  provider            = aws.aws
  cloudwatch_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

resource "aws_iam_role_policy" "cloudwatch" {
  provider = aws.aws
  name     = "default"
  role     = "LabRole"

  policy = data.aws_iam_policy_document.cloudwatch.json
}
