# data "aws_iam_policy_document" "images" {

#   #public read
#   statement {
#     sid     = "PublicReadGetObject"
#     effect  = "Allow"
#     actions = ["s3:GetObject"]
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#     resources = ["${aws_s3_bucket.images.arn}/*"]
#   }
# }


# data "aws_iam_policy_document" "content" {

#   #private
#   statement {
#     sid     = "private"
#     effect  = "Allow"
#     actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#     resources = ["${aws_s3_bucket.content.arn}/*"]
#   }
# }

# resource "aws_s3_bucket" "images" {
#   bucket              = "${local.organization_name}-images"
#   object_lock_enabled = false

#   tags = merge(
#     {
#       "Name" = "${local.organization_name}-images"
#     },
#   )
# }

# resource "aws_s3_bucket_policy" "images" {
#   bucket = aws_s3_bucket.images.id
#   policy = data.aws_iam_policy_document.images.json
# }


# resource "aws_s3_bucket_acl" "images" {
#   bucket = aws_s3_bucket.images.id
#   acl    = "public-read"
# }




# resource "aws_s3_bucket" "content" {
#   bucket              = "${local.organization_name}-content"
#   object_lock_enabled = false

#   tags = merge(
#     {
#       "Name" = "${local.organization_name}-content"
#     },
#   )
# }

# resource "aws_s3_bucket_policy" "content" {
#   bucket = aws_s3_bucket.content.id
#   policy = data.aws_iam_policy_document.content.json
# }


# resource "aws_s3_bucket_acl" "content" {
#   bucket = aws_s3_bucket.content.id
#   acl    = "private"
# }

