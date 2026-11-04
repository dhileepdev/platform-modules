mock_provider "helm" {}

run "renders_error_budget" {
  command = plan
  variables {
    namespace = "monitoring"
    slos = [
      { name = "availability", target = 0.999, window = "28d" },
      { name = "latency", target = 0.99, window = "7d" },
    ]
  }
  assert {
    condition     = strcontains(output.slo_rules_yaml, "slo:availability:error_budget_ratio")
    error_message = "rule name derived from SLO name"
  }
  assert {
    condition     = strcontains(output.slo_rules_yaml, "0.001")
    error_message = "1 - 0.999 must appear as the error budget"
  }
  assert {
    condition     = output.prometheus_service == "kube-prometheus-stack-prometheus"
    error_message = "service naming contract"
  }
}

run "rejects_target_one" {
  command = plan
  variables {
    slos = [{ name = "impossible", target = 1.0, window = "28d" }]
  }
  expect_failures = [var.slos]
}

run "rejects_target_zero" {
  command = plan
  variables {
    slos = [{ name = "meaningless", target = 0, window = "28d" }]
  }
  expect_failures = [var.slos]
}
