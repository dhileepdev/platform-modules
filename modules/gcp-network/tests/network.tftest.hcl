mock_provider "google" {}

run "two_regions" {
  command = plan
  variables {
    name_prefix  = "demo"
    project_id   = "example-project"
    subnet_cidrs = { "asia-south1" = "10.10.0.0/20", "asia-south2" = "10.20.0.0/20" }
  }
  assert {
    condition     = length(output.subnet_ids) == 2
    error_message = "one subnet per region"
  }
  assert {
    condition     = output.network_name == "demo-vpc"
    error_message = "network naming contract"
  }
}

run "rejects_overlapping_cidrs" {
  command = plan
  variables {
    name_prefix  = "demo"
    project_id   = "example-project"
    subnet_cidrs = { "asia-south1" = "10.0.0.0/20", "asia-south2" = "10.0.0.0/20" }
  }
  expect_failures = [google_compute_network.this]
}
