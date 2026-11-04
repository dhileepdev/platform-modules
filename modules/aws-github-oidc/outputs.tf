output "role_arn" {
  description = "ARN of the role GitHub Actions assumes."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the role GitHub Actions assumes."
  value       = aws_iam_role.this.name
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider used by the trust policy."
  value       = local.oidc_provider_arn
}

output "trust_policy_json" {
  description = "Rendered trust policy, useful for policy tests."
  value       = local.trust_policy_json
}
