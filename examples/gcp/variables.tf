variable "project_id" {
  description = "GCP project for the example."
  type        = string
}

variable "region" {
  description = "Region for the network, cluster and node pool."
  type        = string
  default     = "asia-south1"
}

variable "name_prefix" {
  description = "Prefix for every resource name."
  type        = string
  default     = "demo"
}

variable "subnet_cidr" {
  description = "CIDR for the example subnet."
  type        = string
  default     = "10.10.0.0/20"
}

variable "github_org" {
  description = "GitHub organisation that owns the deploying repository."
  type        = string
  default     = "dhileepdev"
}

variable "github_repo" {
  description = "GitHub repository allowed to federate."
  type        = string
  default     = "secure-delivery"
}
