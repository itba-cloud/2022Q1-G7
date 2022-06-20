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

variable "subnet_ids" {
  type        = list(any)
  description = "Subnets ids to be used for the service"
}
