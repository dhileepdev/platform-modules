locals {
  subnet_ranges = [
    for region, cidr in var.subnet_cidrs : {
      region = region
      start  = sum([for i, octet in split(".", cidrhost(cidr, 0)) : tonumber(octet) * pow(256, 3 - i)])
      size   = pow(2, 32 - tonumber(split("/", cidr)[1]))
    }
  ]

  overlapping_subnets = [
    for i, a in local.subnet_ranges : a.region
    if length([
      for j, b in local.subnet_ranges : b.region
      if i < j && a.start < b.start + b.size && b.start < a.start + a.size
    ]) > 0
  ]
}

resource "google_compute_network" "this" {
  name                    = "${var.name_prefix}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  description = "Managed by platform-modules: ${var.name_prefix}"

  lifecycle {
    precondition {
      condition     = length(local.overlapping_subnets) == 0
      error_message = "subnet_cidrs must not overlap; conflicting regions: ${join(", ", local.overlapping_subnets)}."
    }
  }
}

resource "google_compute_subnetwork" "this" {
  for_each = var.subnet_cidrs

  name          = "${var.name_prefix}-${each.key}"
  project       = var.project_id
  region        = each.key
  network       = google_compute_network.this.id
  ip_cidr_range = each.value

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []

    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_firewall" "deny_all_ingress" {
  name      = "${var.name_prefix}-deny-all-ingress"
  project   = var.project_id
  network   = google_compute_network.this.name
  direction = "INGRESS"
  priority  = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]

  description = "Default deny; allow rules are added by the caller."
}
