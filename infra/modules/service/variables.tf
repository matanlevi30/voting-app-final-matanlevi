# Inputs of the service module

variable "name" {
  description = "Full name of the service, for example matan-final-dev-vote"
  type        = string
}

variable "container_name" {
  description = "Name of the container inside the task, for example vote"
  type        = string
}

variable "image" {
  description = "Full image URI: <ECR repository URL>:<tag>"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "execution_role_arn" {
  description = "Task execution role (pull from ECR, write logs, read the secret)"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for the tasks"
  type        = list(string)
}

variable "desired_count" {
  description = "Number of tasks"
  type        = number
}

variable "cpu" {
  description = "CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 512
}

variable "environment" {
  description = "Plain environment variables: name => value"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets: environment variable name => Secrets Manager ARN"
  type        = map(string)
  default     = {}
}

variable "container_port" {
  description = "Port of the container. null = no port (worker)"
  type        = number
  default     = null
}

variable "target_group_arn" {
  description = "Target group to register in. null = not behind the load balancer (worker)"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "How long CloudWatch keeps the logs"
  type        = number
  default     = 7
}