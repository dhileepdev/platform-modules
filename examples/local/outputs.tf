output "cluster_name" {
  description = "kind cluster name."
  value       = module.kind.cluster_name
}

output "context" {
  description = "kubectl context for the cluster."
  value       = module.kind.context
}
