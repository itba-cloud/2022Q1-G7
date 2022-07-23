variable "name" {
  description = "Name of the API"
  type        = string
}
variable "protocol_type" {
  description = "Protocol type of the API"
  type        = string
}
variable "integrations" {
  description = "Integrations of the API"
  type        = list(any)
  default     = []
}
variable "routes" {
  description = "Routes of the API"
  type        = list(any)
  default     = []
}

variable "stages" {
  description = "Stages of the API"
  type        = list(any)
  default     = []
}

variable "authorizers" {
  description = "Authorizers of the API"
  type        = list(any)
  default     = []
}
