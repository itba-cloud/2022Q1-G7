# ------------------------------------------------------------------------
# Amazon S3 variables
# ------------------------------------------------------------------------

variable "website_name" {
  type        = string
  description = "The name of the presentation tier. Must be less than or equal to 63 characters in length."
}

variable "objects" {
  type        = map(any)
  description = ""
  default     = {}
}

variable "www_bucket_tags" {
  type        = map(string)
  description = "Tags for the www website bucket."
  default     = {}
}

variable "bucket_tags" {
  type        = map(string)
  description = "Tags for the official website bucket."
  default     = {}
}

variable "bucket_log_tags" {
  type        = map(string)
  description = "Tags for the logs website bucket."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags for all the buckets."
  default     = {}
}
