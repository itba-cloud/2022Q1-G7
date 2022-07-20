data "aws_iam_policy_document" "images" {

  provider = aws.aws

  #public read
  statement {
    sid     = "PublicReadGetObject"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.images.arn}/*"]
  }
}


data "aws_iam_policy_document" "content" {

  provider = aws.aws

  #private
  statement {
    sid     = "private"
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"]
    }
    resources = ["${aws_s3_bucket.content.arn}/*"]
  }
}

resource "aws_s3_bucket" "images" {
  provider            = aws.aws
  bucket              = "${local.organization}-images"
  object_lock_enabled = false

  tags = merge(
    {
      "Name" = "${local.organization}-images"
    },
  )
}

resource "aws_s3_bucket_policy" "images" {
  provider = aws.aws
  bucket   = aws_s3_bucket.images.id
  policy   = data.aws_iam_policy_document.images.json
}


resource "aws_s3_bucket_acl" "images" {
  provider = aws.aws
  bucket   = aws_s3_bucket.images.id
  acl      = "public-read"
}




resource "aws_s3_bucket" "content" {
  provider            = aws.aws
  bucket              = "${local.organization}-content"
  object_lock_enabled = false

  tags = merge(
    {
      "Name" = "${local.organization}-content"
    },
  )
}

resource "aws_s3_bucket_policy" "content" {
  provider = aws.aws
  bucket   = aws_s3_bucket.content.id
  policy   = data.aws_iam_policy_document.content.json
}


resource "aws_s3_bucket_acl" "content" {
  provider = aws.aws
  bucket   = aws_s3_bucket.content.id
  acl      = "private"
}

