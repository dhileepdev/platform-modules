variable "name_prefix" {
  description = "Prefix for the cluster and node pool names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name_prefix))
    error_message = "name_prefix must match ^[a-z][a-z0-9-]{1,20}$."
  }
}

variable "project_id" {
  description = "GCP project that owns the cluster."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID."
  }
}

variable "region" {
  description = "Region for the cluster and node pool."
  type        = string

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))
    error_message = "region must look like asia-south1."
  }
}

variable "network_id" {
  description = "ID of the VPC network."
  type        = string
}

variable "subnetwork_id" {
  description = "ID of the subnetwork. Null uses the network's default subnetwork for the region."
  type        = string
  default     = null
}

variable "machine_type" {
  description = "Node machine type."
  type        = string
  default     = "e2-small"

  validation {
    condition = contains(
      ["e2", "n1", "n2", "n2d", "c3", "c4", "t2d", "t2a", "a3", "g2"],
      split("-", var.machine_type)[0]
    )
    error_message = "machine_type must belong to a known GCP machine family (e2, n1, n2, n2d, c3, c4, t2d, t2a, a3, g2)."
  }
}

variable "node_count" {
  description = "Nodes per zone in the managed node pool."
  type        = number
  default     = 2

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 3
    error_message = "node_count must be between 1 and 3."
  }
}

variable "release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be one of RAPID, REGULAR or STABLE."
  }
}

variable "enable_private_nodes" {
  description = "Give nodes private RFC1918 addresses only."
  type        = bool
  default     = true
}

variable "master_ipv4_cidr_block" {
  description = "CIDR reserved for the control plane when private nodes are enabled."
  type        = string
  default     = "172.16.0.0/28"

  validation {
    condition     = can(cidrnetmask(var.master_ipv4_cidr_block))
    error_message = "master_ipv4_cidr_block must be a valid IPv4 CIDR."
  }
}

variable "tags" {
  description = "Labels applied to the cluster and node pool."
  type        = map(string)
  default     = {}
}
