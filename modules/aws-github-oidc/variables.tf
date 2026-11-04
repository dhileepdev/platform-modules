variable "name_prefix" {
  description = "Prefix for the role name. Lowercase letters, digits and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name_prefix))
    error_message = "name_prefix must match ^[a-z][a-z0-9-]{1,20}$."
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
  description = "GitHub repository allowed to assume the role."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9._-]+$", var.github_repo))
    error_message = "github_repo must match ^[A-Za-z0-9._-]+$."
  }
}

variable "allowed_refs" {
  description = "Git refs, such as refs/heads/main, allowed to assume the role. Wildcards are accepted only inside a ref."
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

variable "create_oidc_provider" {
  description = "Create the GitHub OIDC provider. Set false when it already exists in the account."
  type        = bool
  default     = true
}

variable "managed_policy_arns" {
  description = "Managed policies attached to the role, in addition to the GetCallerIdentity inline policy."
  type        = list(string)
  default     = []
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds."
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 and 43200 seconds."
  }
}
