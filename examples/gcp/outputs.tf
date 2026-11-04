output "cluster_name" {
  description = "GKE cluster name."
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "GKE control plane endpoint."
  value       = module.gke.cluster_endpoint
}

output "workload_identity_provider" {
  description = "WIF provider for google-github-actions/auth."
  value       = module.github_wif.workload_identity_provider
}

output "service_account_email" {
  description = "Service account GitHub Actions impersonates."
  value       = module.github_wif.service_account_email
}
