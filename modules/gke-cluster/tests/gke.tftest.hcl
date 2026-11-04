mock_provider "google" {}

run "zonal_defaults" {
  command = plan
  variables {
    name_prefix = "demo"
    project_id  = "example-project"
    region      = "asia-south1"
    network_id  = "projects/example-project/global/networks/demo-vpc"
  }
  assert {
    condition     = output.cluster_name == "demo-gke"
    error_message = "cluster naming contract"
  }
  assert {
    condition     = output.workload_identity_pool == "example-project.svc.id.goog"
    error_message = "workload identity pool derived from project"
  }
}

run "rejects_bad_machine_type" {
  command = plan
  variables {
    name_prefix  = "demo"
    project_id   = "example-project"
    region       = "asia-south1"
    network_id   = "projects/example-project/global/networks/demo-vpc"
    machine_type = "not-a-machine"
  }
  expect_failures = [var.machine_type]
}
