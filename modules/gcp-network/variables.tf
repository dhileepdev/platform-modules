variable "name_prefix" {
  description = "Prefix for every resource name. Lowercase letters, digits and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name_prefix))
    error_message = "name_prefix must match ^[a-z][a-z0-9-]{1,20}$."
  }
}

variable "project_id" {
  description = "GCP project that owns the network."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID."
  }
}

variable "subnet_cidrs" {
  description = "Map of region to subnet CIDR. Regions are the keys; CIDRs must not overlap."
  type        = map(string)

  validation {
    condition     = length(var.subnet_cidrs) > 0
    error_message = "subnet_cidrs must contain at least one region."
  }

  validation {
    condition = alltrue([
      for cidr in values(var.subnet_cidrs) : can(cidrnetmask(cidr))
    ])
    error_message = "Every subnet CIDR must be valid IPv4 CIDR notation."
  }
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs on every subnet."
  type        = bool
  default     = true
}
