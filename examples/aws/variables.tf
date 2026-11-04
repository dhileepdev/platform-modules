variable "region" {
  description = "AWS region for every resource."
  type        = string
  default     = "ap-south-1"
}

variable "name_prefix" {
  description = "Prefix for every resource name."
  type        = string
  default     = "demo"
}

variable "vpc_cidr" {
  description = "CIDR for the demo VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "caller_cidr" {
  description = "Public IP of the operator, as a /32, allowed to reach the EKS API."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.caller_cidr)) && tonumber(split("/", var.caller_cidr)[1]) == 32
    error_message = "caller_cidr must be a single host /32."
  }
}
