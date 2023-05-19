variable "project" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "region" {
  description = "Region AWS where deploy occurs"
  type        = string
}

variable "environment" {
  type = string
  validation {
    condition     = length(regex("^(prd|stg|hml|dev)", var.environment)) == 1
    error_message = "Environment should contain prd or stg or hml or dev."
  }
}

variable "server_name" {
  type        = string
  description = "Server Name"
}


variable "organization_name" {
  type        = string
  description = "Name of Main organization in TLS"
}

variable "download_certs" {
  type        = bool
  description = "value"
  default     = false
}

variable "hosted_zone" {
  type        = string
  description = "Hosted Zone to be added to main account for internal resources"
}

variable "route53_by_environment" {
  type        = bool
  description = "Use the default name as a resource"
  default     = true
}

