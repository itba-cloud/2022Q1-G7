# ------------------------------------------------------------------------------
# Amazon S3
# ------------------------------------------------------------------------------

# 1 - S3 bucket
resource "aws_s3_bucket" "this" {
    bucket              = var.bucket_name
    object_lock_enabled = false
}

# 2 -Bucket policy
resource "aws_s3_bucket_policy" "this" {
    count = var.objects != {} ? 1 : 0

    bucket = aws_s3_bucket.this.id
    policy = data.aws_iam_policy_document.this.json
}

# 3 -Website configuration
resource "aws_s3_bucket_website_configuration" "this" {
    bucket = aws_s3_bucket.this.id

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }
}

# 4 - Access Control List
resource "aws_s3_bucket_acl" "this" {
    bucket = aws_s3_bucket.this.id
    acl    = var.bucket_acl
}

# 5 - Upload objects
resource "aws_s3_object" "this" {
    for_each =  try(var.objects, {}) #{ for object, key in var.objects: object => key if try(var.objects, {}) != {} }

    bucket        = aws_s3_bucket.this.id
    key           = try(each.value.rendered, replace(each.value.filename, "html/", "")) # remote path
    source        = try(each.value.rendered, format("../../resources/%s", each.value.filename)) # where is the file located
    content_type  = each.value.content_type
    storage_class = try(each.value.tier, "STANDARD")
}