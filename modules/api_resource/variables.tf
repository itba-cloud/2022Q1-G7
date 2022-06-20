# ------------------------------------------------------------------------
# api resource variables
# ------------------------------------------------------------------------

variable "api_id" {
  description = "The ID of the API resource"
  type        = string
}

variable "parent_id" {
  description = "The ID of the root resource of the API resource"
  type        = string
}

variable "part" {
  description = "The path of the API resource"
  type        = string
}

variable "methods" {
  description = "The methods of the API resource"
  type        = map(any)
}


