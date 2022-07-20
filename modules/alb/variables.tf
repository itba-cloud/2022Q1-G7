variable "name" {
  type        = string
  description = "The name of the resource"
}

variable "internal" {
  type        = bool
  description = "The internal flag of the resource"
}

variable "subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets of the resource"
}

variable "target_groups" {
  type = list(object({
    name              = string,
    health_check_path = string,
  }))
  description = "variables of the target groups of the resource"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC of the resource"
}
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to the service"
  default     = {}
}

variable "security_group_tags" {
  type        = map(string)
  description = "Tags to be applied to the security group"
  default     = {}
}

variable "load_balancer_tags" {
  type        = map(string)
  description = "Tags to be applied to the load balancer"
  default     = {}
}

variable "target_group_tags" {
  type        = map(string)
  description = "Tags to be applied to the load balancer security groups"
  default     = {}
}

variable "listener_tags" {
  type        = map(string)
  description = "Tags to be applied to the load balancer listener"
  default     = {}
}

variable "sg_ingress" {
  description = "Ingress security group"
  type        = list(any)
  default     = []
}
variable "sg_egress" {
  description = "Egress security group"
  type        = list(any)
  default     = []
}
