variable "name_prefix" {
  description = "Prefix for every resource name. Lowercase letters, digits and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name_prefix))
    error_message = "name_prefix must match ^[a-z][a-z0-9-]{1,20}$."
  }
}

variable "vpc_cidr" {
  description = "CIDR for the VPC. Prefix must be between 16 and 21 so every subnet can be a /24."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition = (
      can(cidrnetmask(var.vpc_cidr)) &&
      tonumber(split("/", var.vpc_cidr)[1]) >= 16 &&
      tonumber(split("/", var.vpc_cidr)[1]) <= 21
    )
    error_message = "vpc_cidr must be a valid IPv4 CIDR with a prefix between /16 and /21."
  }
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 3
    error_message = "az_count must be between 1 and 3."
  }
}

variable "enable_flow_logs" {
  description = "Send VPC flow logs to a CloudWatch log group."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all private subnets instead of one per AZ."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to every taggable resource."
  type        = map(string)
  default     = {}
}
