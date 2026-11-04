locals {
  cluster_name = "${var.name_prefix}-gke"
  node_pool    = "${var.name_prefix}-gke-nodes"
  wif_pool     = "${var.project_id}.svc.id.goog"
}

resource "google_container_cluster" "this" {
  name     = local.cluster_name
  project  = var.project_id
  location = var.region

  network    = var.network_id
  subnetwork = var.subnetwork_id


  release_channel {
    channel = var.release_channel
  }

  workload_identity_config {
    workload_pool = local.wif_pool
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # The example is timeboxed and destroyed on purpose.
  deletion_protection = false

  resource_labels = var.tags
}

resource "google_container_node_pool" "this" {
  name     = local.node_pool
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.this.name

  node_count = var.node_count

  node_config {
    machine_type = var.machine_type

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = var.tags
  }
}
