// Name Prefix; can be overidden at resource level.

variable "name" {
  description = "Common name to be used for all provisioned AWS resources except additional resources. For naming additional resources of same type, specify `name_override` in individual modules"
  type        = string
  validation {
    condition     = length(var.name) > 0
    error_message = "Common name is too short."
  }
}

// Global Tags
variable "product" {
  description = "Platform product name."
  type        = string
  validation {
    condition     = length(var.product) > 0
    error_message = "Platform product name is too short."
  }
}

variable "environment" {
  type = string
  validation {
    condition     = length(regex("^(prd|stg|hml|dev)", var.environment)) == 1
    error_message = "Environment should contain prd or stg or hml or dev."
  }
  default = "prd"
}

variable "cost_center" {
  description = "Cost Center for chargeback."
  type        = string
  default     = "000000-00"
  validation {
    condition     = length(var.cost_center) > 0
    error_message = "Cost Center name is too short."
  }
}

variable "owner" {
  description = "Team DL for the product team."
  type        = string
  validation {
    condition     = length(var.owner) > 0
    error_message = "Owner name is too short."
  }
}

variable "platform_version" {
  description = "Version of Platform used to provision infrastructure"
  type        = string
  validation {
    condition     = length(var.platform_version) > 0
    error_message = "Platform version is too short."
  }
}

// Service Related Tags; can be overidden at resource level.
variable "service_name" {
  description = "Application service name"
  type        = string
  validation {
    condition     = length(var.service_name) > 0
    error_message = "Service name is too short."
  }
}

variable "service_version" {
  description = "Version of the application service"
  type        = string
  default     = "0.0.1"
  validation {
    condition     = length(var.service_version) > 0
    error_message = "Service version is too short."
  }
}

variable "additional_tags" {
  type    = map(any)
  default = {}
}
