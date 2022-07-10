# ---------------------------------------------------------------------------
# ECS datasources
# ---------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "token" {}

data "aws_region" "current" {
}