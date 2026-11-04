variable "name_prefix" {
  description = "Prefix for every resource name. Lowercase letters, digits and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name_prefix))
    error_message = "name_prefix must match ^[a-z][a-z0-9-]{1,20}$."
  }
}

variable "cluster_version" {
  description = "Kubernetes version for the control plane."
  type        = string
  default     = "1.33"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.cluster_version))
    error_message = "cluster_version must look like 1.33."
  }
}

variable "subnet_ids" {
  description = "Private subnet IDs for the control plane and nodes."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet."
  }
}

variable "node_instance_types" {
  description = "Instance types for the managed node group."
  type        = list(string)
  default     = ["t3.small"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "node_instance_types must contain at least one instance type."
  }
}

variable "node_desired_size" {
  description = "Desired number of nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes."
  type        = number
  default     = 3

  validation {
    condition     = var.node_max_size >= var.node_desired_size
    error_message = "node_max_size must be greater than or equal to node_desired_size."
  }
}

variable "endpoint_public_access" {
  description = "Expose the cluster API endpoint publicly."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach a public endpoint. Required when endpoint_public_access is true."
  type        = list(string)
  default     = []

  validation {
    condition     = !var.endpoint_public_access || length(var.public_access_cidrs) > 0
    error_message = "public_access_cidrs must contain at least one CIDR when endpoint_public_access is true."
  }

  validation {
    condition = alltrue([
      for cidr in var.public_access_cidrs :
      can(cidrnetmask(cidr)) && tonumber(split("/", cidr)[1]) == 32
    ])
    error_message = "Every public_access_cidrs entry must be a single host /32."
  }
}

variable "tags" {
  description = "Tags applied to every taggable resource."
  type        = map(string)
  default     = {}
}
