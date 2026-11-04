variable "name_prefix" {
  description = "Prefix for the service account display name. Lowercase letters, digits and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name_prefix))
    error_message = "name_prefix must match ^[a-z][a-z0-9-]{1,20}$."
  }
}

variable "project_id" {
  description = "GCP project that owns the pool, provider and service account."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID."
  }
}

variable "pool_id" {
  description = "Workload identity pool ID."
  type        = string
  default     = "gha-pool"

  validation {
    condition     = can(regex("^[a-z0-9-]{4,32}$", var.pool_id))
    error_message = "pool_id must be 4-32 lowercase letters, digits or hyphens."
  }
}

variable "provider_id" {
  description = "Workload identity pool provider ID."
  type        = string
  default     = "gha-provider"

  validation {
    condition     = can(regex("^[a-z0-9-]{4,32}$", var.provider_id))
    error_message = "provider_id must be 4-32 lowercase letters, digits or hyphens."
  }
}

variable "service_account_id" {
  description = "Service account ID the workload identity pool impersonates."
  type        = string
  default     = "gha-deployer"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.service_account_id))
    error_message = "service_account_id must be 6-30 lowercase letters, digits or hyphens."
  }
}

variable "github_org" {
  description = "GitHub organisation or user that owns the repository."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+$", var.github_org))
    error_message = "github_org must match ^[A-Za-z0-9-]+$."
  }
}

variable "github_repo" {
  description = "GitHub repository allowed to federate."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9._-]+$", var.github_repo))
    error_message = "github_repo must match ^[A-Za-z0-9._-]+$."
  }
}

variable "allowed_refs" {
  description = "Git refs, such as refs/heads/main, allowed to federate."
  type        = list(string)

  validation {
    condition     = length(var.allowed_refs) > 0
    error_message = "allowed_refs must contain at least one ref."
  }

  validation {
    condition = alltrue([
      for ref in var.allowed_refs :
      ref != "*" && can(regex("^refs/(heads|tags|pull)/.+$", ref))
    ])
    error_message = "Every entry must look like refs/heads/<branch>, refs/tags/<tag> or refs/pull/<id>; the bare wildcard \"*\" is not allowed."
  }
}

variable "roles" {
  description = "Project roles granted to the service account."
  type        = list(string)
  default     = ["roles/viewer"]

  validation {
    condition     = length(var.roles) > 0
    error_message = "roles must contain at least one role."
  }

  validation {
    condition     = alltrue([for role in var.roles : can(regex("^roles/[a-zA-Z0-9_]+$", role))])
    error_message = "Every role must look like roles/<name>."
  }
}
