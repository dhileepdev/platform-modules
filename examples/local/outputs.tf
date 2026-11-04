output "cluster_name" {
  description = "kind cluster name."
  value       = module.kind.cluster_name
}

output "context" {
  description = "kubectl context for the cluster."
  value       = module.kind.context
}

output "github_role_arn" {
  description = "ARN of the local GitHub Actions role."
  value       = module.github_oidc.role_arn
}

output "github_role_name" {
  description = "Name of the local GitHub Actions role."
  value       = module.github_oidc.role_name
}
