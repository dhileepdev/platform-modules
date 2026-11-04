output "service_account_email" {
  description = "Email of the service account GitHub Actions impersonates."
  value       = google_service_account.this.email
}

output "workload_identity_provider" {
  description = "Full WIF provider name for google-github-actions/auth."
  value       = "//iam.googleapis.com/${google_iam_workload_identity_pool_provider.this.name}"
}
