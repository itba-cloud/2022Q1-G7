# ---------------------------------------------------------------------------
# Amazon CloudWatch
# ---------------------------------------------------------------------------

# resource "aws_sns_topic" "this" {
#   name = "apigw-alarm-topic"
# }

# resource "aws_cloudwatch_metric_alarm" "this" {
#   alarm_name          = "apigw_alarm"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "Latency"
#   namespace           = "AWS/ApiGateway"
#   period              = "300"
#   statistic           = "Average"
#   threshold           = "10000.0"
#   alarm_description   = "Monitoring API GW requests"
#   alarm_actions       = [aws_sns_topic.this.arn]

#   dimensions = {
#     ApiName = var.service_to_monitor
#     Stage   = "production"
#   }
# }

resource "aws_api_gateway_account" "this" {
  provider            = aws.aws
  cloudwatch_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

resource "aws_iam_role_policy" "cloudwatch" {
  provider = aws.aws
  name     = "default"
  role     = "LabRole"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
