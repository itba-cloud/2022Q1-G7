variable "hosted_zone_name" {
  description = "The name of the hosted zone"
  default     = ""
  type        = string
}

variable "records" {
  description = "The records to create"
  default     = []
  type        = list(any)
}

variable "vpc_id" {
  description = "The VPC ID"
  default     = ""
  type        = string
}

variable "alias" {
  description = "The alias to create"
  default     = {}
  type        = map(any)
}
