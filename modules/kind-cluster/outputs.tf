output "cluster_name" {
  description = "Name of the kind cluster."
  value       = local.cluster_name
}

output "context" {
  description = "kubectl context for the cluster."
  value       = "kind-${local.cluster_name}"
}

output "cluster_ready" {
  description = "True once kind create cluster has returned."
  value       = true
}
