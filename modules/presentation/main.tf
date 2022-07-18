# ------------------------------------------------------------------------------
# Amazon S3
# ------------------------------------------------------------------------------

# 1 - S3 bucket
resource "aws_s3_bucket" "www" {
  bucket = "www.${var.website_name}"
  tags = merge(
    {
      "Name" = "www.${var.website_name}"
    },
    var.tags,
    var.www_bucket_tags
  )
}

resource "aws_s3_bucket" "this" {
  bucket = var.website_name
  tags = merge(
    {
      "Name" = var.website_name
    },
    var.tags,
    var.bucket_tags
  )
}
resource "aws_s3_bucket" "logs" {
  bucket = "logs.${var.website_name}"
  tags = merge(
    {
      "Name" = "${var.website_name}-logs"
    },
    var.tags,
    var.bucket_log_tags
  )
}

# 2 -Bucket policy
resource "aws_s3_bucket_policy" "this" {
  count = var.objects != {} ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}


# 3 -Website configuration

resource "aws_s3_bucket_acl" "www" {
  bucket = aws_s3_bucket.www.id
  acl    = "public-read"
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "public-read"
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id

  redirect_all_requests_to {
    host_name = var.website_name
    protocol  = "https"
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_logging" "this" {
  bucket = aws_s3_bucket.this.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "log/"
}

# 5 - Upload objects
resource "aws_s3_object" "this" {
  for_each = try(var.objects, {}) #{ for object, key in var.objects: object => key if try(var.objects, {}) != {} }

  bucket        = aws_s3_bucket.this.id
  key           = try(each.value.rendered, replace(each.value.filename, "html/", ""))         # remote path
  source        = try(each.value.rendered, format("../../resources/%s", each.value.filename)) # where is the file located
  content_type  = each.value.content_type
  storage_class = try(each.value.tier, "STANDARD")
}
