output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = module.eks.cluster_endpoint
}

output "github_role_arn" {
  description = "Role GitHub Actions assumes."
  value       = module.github_oidc.role_arn
}

output "vpc_id" {
  description = "Demo VPC ID."
  value       = module.network.vpc_id
}
