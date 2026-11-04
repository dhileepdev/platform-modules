output "cluster_name" {
  description = "Name of the GKE cluster."
  value       = google_container_cluster.this.name
}

output "cluster_endpoint" {
  description = "Control plane endpoint."
  value       = google_container_cluster.this.endpoint
}

output "ca_certificate" {
  description = "Base64-encoded cluster CA certificate."
  value       = try(google_container_cluster.this.master_auth[0].cluster_ca_certificate, null)
  sensitive   = true
}

output "workload_identity_pool" {
  description = "Workload identity pool bound to the cluster's Kubernetes service accounts."
  value       = local.wif_pool
}
