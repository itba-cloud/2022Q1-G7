# ------------------------------------------------------------------------
# ECS Task definition variables
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
  type        = list(any)
  description = "Tags to be applied to the task definition"
  default     = []
}

variable "task_role_arn" {
  type        = string
  description = "ARN of the task role"
}

variable "execution_role_arn" {
  type        = string
  description = "ARN of the execution role"
}
# ------------------------------------------------------------------------
# ECS Cluster variables
# ------------------------------------------------------------------------
variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "cluster_tags" {
  type        = list(any)
  description = "Tags to be applied to the cluster"
  default     = []
}
# ------------------------------------------------------------------------
# ECS Service variables
# ------------------------------------------------------------------------
variable "services" {
  type = map(object({
    "name"            = string
    "image"           = string
    "desiredCount"   = integer
    "containerPort"   = integer
    "hostPort"        = integer
  }))
  description = "Name of the service"
}

variable "container_count" {
  type        = string
  description = "Number of containers to be deployed"
}
