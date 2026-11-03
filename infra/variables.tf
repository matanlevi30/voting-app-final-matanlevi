# All the input variables, with validation blocks
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "env" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "env must be dev or prod."
  }
}

variable "name_prefix" {
  description = "Prefix for every name. Lowercase letters, digits and hyphens, up to 12 characters"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{1,12}$", var.name_prefix))
    error_message = "name_prefix: lowercase letters, digits and hyphens, up to 12 characters."
  }
}

variable "vpc_cidr" {
  description = "CIDR range of the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR, for example 10.10.0.0/16."
  }
}

variable "image_tag" {
  description = "Tag of the images in ECR (the git commit SHA in the pipeline)"
  type        = string
}

variable "desired_count" {
  description = "Number of tasks per service"
  type        = number
}

variable "option_a" {
  description = "First option on the vote page"
  type        = string
  default     = "ביבי"
}

variable "option_b" {
  description = "Second option on the vote page"
  type        = string
  default     = "אייזנקוט"
}
