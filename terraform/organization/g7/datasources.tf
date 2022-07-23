# ---------------------------------------------------------------------------
# Main resources
# ---------------------------------------------------------------------------

data "aws_region" "current" {
  provider = aws.aws
}

data "aws_caller_identity" "current" {
  provider = aws.aws
}
data "aws_iam_policy_document" "cloudwatch" {
  version = "2012-10-17"
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]

    resources = [
      "*",
    ]
  }
}
