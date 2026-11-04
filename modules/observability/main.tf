locals {
  slo_rule_groups = [
    for slo in var.slos : {
      name = "slo-${slo.name}"
      rules = [
        {
          record = "slo:${slo.name}:objective"
          expr   = tostring(slo.target)
        },
        {
          record = "slo:${slo.name}:error_budget_ratio"
          expr   = format("%.6f", 1 - slo.target)
        },
        {
          alert = "SLO${title(replace(slo.name, "-", "_"))}ErrorBudgetBurn"
          expr = join("", [
            "sum(rate(http_requests_total{job=~\".+\",code=~\"5..\"}[",
            slo.window,
            "])) / sum(rate(http_requests_total{job=~\".+\"}[",
            slo.window,
            "])) > ",
            format("%.6f", 1 - slo.target),
          ])
          for = "5m"
          labels = {
            severity = "warning"
            slo      = slo.name
          }
          annotations = {
            summary = "Error budget burn above target for ${slo.name}"
            runbook = "docs/runbooks/observability.md"
          }
        },
      ]
    }
  ]

  slo_rules_map  = { for group in local.slo_rule_groups : group.name => { groups = [group] } }
  slo_rules_yaml = yamlencode(local.slo_rules_map)

  grafana_values = merge(
    {},
    var.grafana_admin_password == null ? {} : { adminPassword = var.grafana_admin_password },
  )

  alertmanager_values = var.alert_webhook_url == null ? {} : {
    config = {
      route = {
        receiver = "default"
        group_by = ["alertname"]
      }
      receivers = [{
        name            = "default"
        webhook_configs = [{ url = var.alert_webhook_url }]
      }]
    }
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = var.namespace
  create_namespace = true
  timeout          = 900

  values = [
    yamlencode({
      additionalPrometheusRulesMap = local.slo_rules_map
      prometheus = {
        prometheusSpec = {
          retention = var.prometheus_retention
        }
      }
      grafana      = local.grafana_values
      alertmanager = local.alertmanager_values
    }),
  ]
}
