variable "project" {
  type        = string
  description = "Name to be used on all the resources as identifier"
}

variable "environment" {
  type        = string
  description = "The environment, and also used as a identifier"
}

variable "region" {
  type        = string
  description = "Region AWS where deploy occurs"
}

variable "vpc_main_cidr_block" {
  default     = "172.10.0.0/20"
  description = "Range of IPv4 address for the VPC main"
}

variable "subnet_size" {
  default     = 8
  description = "Range of IPv4 address for the subnet"
}

variable "azs" {
  type        = list(string)
  description = "Availiablity zones where to put subnets"
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "Should receive a structured tag from tag module"
}
