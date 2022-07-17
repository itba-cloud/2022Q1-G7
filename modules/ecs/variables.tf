# ------------------------------------------------------------------------
# ECS variables
# ------------------------------------------------------------------------
variable "container_cpu" {
  type        = string
  description = "CPUs to be allocated to the container"
}

variable "container_memory" {
  type        = string
  description = "Memory to be allocated to the container"
}

variable "task_definition_tags" {
  type        = map(string)
  description = "Tags to be applied to the task definition"
  default     = {}
}

variable "task_role_arn" {
  type        = string
  description = "ARN of the task role"
}

variable "execution_role_arn" {
  type        = string
  description = "ARN of the execution role"
}

variable "cluster_tags" {
  type        = map(string)
  description = "Tags to be applied to the cluster"
  default     = {}
}

variable "services" {
  type = list(object({
    name          = string
    image         = string
    location      = string
    replicas      = number
    containerPort = number
  }))
  description = "Name of the service"
}


variable "name" {
  type        = string
  description = "Name of the service"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnet_ids" {
  type        = list(any)
  description = "Subnets ids to be used for the service"
}

variable "private_subnet_ids" {
  type        = list(any)
  description = "Subnets ids to be used for the service"
}

variable "security_group_tags" {
  type        = map(string)
  description = "Tags to be applied to the security group"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to the service"
  default     = {}
}

variable "public_alb_tags" {
  type = object({
    listener_tags       = map(string),
    target_group_tags   = map(string),
    load_balancer_tags  = map(string),
    security_group_tags = map(string),
    tags                = map(string),
  })
  description = "Tags to be applied to the ALB"
  default = {
    listener_tags       = {},
    target_group_tags   = {},
    load_balancer_tags  = {},
    security_group_tags = {},
    tags                = {},
  }
}
variable "private_alb_tags" {
  type = object({
    listener_tags       = map(string),
    target_group_tags   = map(string),
    load_balancer_tags  = map(string),
    security_group_tags = map(string),
    tags                = map(string),
  })
  description = "Tags to be applied to the ALB"
  default = {
    listener_tags       = {},
    target_group_tags   = {},
    load_balancer_tags  = {},
    security_group_tags = {},
    tags                = {},
  }
}

variable "logs_region" {
  description = "AWS region for logs"
  type        = string
}


variable "health_check_path" {
  description = "Path to be used for health check"
  type        = string
}