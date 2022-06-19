# ------------------------------------------------------------------------
# Amazon S3 variables
# ------------------------------------------------------------------------

variable "bucket_name" {
  type        = string
  description = "The name of the bucket. Must be less than or equal to 63 characters in length."
}

variable "objects" {
  type        = map(any)
  description = ""
  default     = {}
}

variable "block_public_access" {
  type        = bool
  default     = true
  description = "Determines the S3 account-level Public Access Block configuration. For more information about these settings, see the AWS S3 documentation: https://docs.aws.amazon.com/AmazonS3/latest/dev/access-control-block-public-access.html"
}

variable "bucket_acl" {
  type        = string
  default     = "private" 
  description = "The canned ACL to apply. Valid values are private, public-read, public-read-write, aws-exec-read, authenticated-read, and log-delivery-write. Defaults to private. For more information about these settings, see the AWS S3 documentation: https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl"
}