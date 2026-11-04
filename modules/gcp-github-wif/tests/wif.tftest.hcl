mock_provider "google" {
  mock_resource "google_iam_workload_identity_pool_provider" {
    defaults = {
      name = "projects/example-project/locations/global/workloadIdentityPools/gha-pool/providers/gha-provider"
    }
    override_during = plan
  }
}

run "provider_path" {
  command = plan
  variables {
    name_prefix  = "gha"
    project_id   = "example-project"
    github_org   = "dhileepdev"
    github_repo  = "secure-delivery"
    allowed_refs = ["refs/heads/main"]
  }
  assert {
    condition     = strcontains(output.workload_identity_provider, "//iam.googleapis.com/projects/example-project/locations/global/workloadIdentityPools/gha-pool/providers/gha-provider")
    error_message = "WIF provider path contract"
  }
}
