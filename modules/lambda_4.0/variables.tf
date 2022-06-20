# ------------------------------------------------------------------------
# Lambda variables
# ------------------------------------------------------------------------

variable "name" {
  type        = string
  description = "The name of the lambda"
}

variable "path" {
  type        = string
  description = "The path to the lambda directory"
}

variable "principal" {
  type        = string
  description = "The principal that can invoke the lambda"
}
