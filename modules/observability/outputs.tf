output "namespace" {
  description = "Namespace the monitoring stack runs in."
  value       = helm_release.kube_prometheus_stack.namespace
}

output "grafana_service" {
  description = "Grafana service name."
  value       = "${helm_release.kube_prometheus_stack.name}-grafana"
}

output "prometheus_service" {
  description = "Prometheus service name."
  value       = "${helm_release.kube_prometheus_stack.name}-prometheus"
}

output "slo_rules_yaml" {
  description = "Rendered additionalPrometheusRulesMap values for the configured SLOs."
  value       = local.slo_rules_yaml
}
