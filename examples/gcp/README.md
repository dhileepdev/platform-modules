# GCP example

This example is mock-tested and has never been applied. `gcloud` is installed, but no GCP project or billing account was available, and no GCP resource was created. The configuration is complete; treat it as a reviewed starting point.

It wires `gcp-network` → `gke-cluster` → `gcp-github-wif` → `observability` with the same modules the local and AWS examples use.

## Check it without a project

```bash
terraform -chdir=examples/gcp init -backend=false
terraform -chdir=examples/gcp validate
```

`terraform validate` needs no credentials. `terraform plan` does, which is why CI stops at validate for this example.

## What would need changing before a real apply

- `project_id` must exist and have the GKE, Compute and IAM APIs enabled.
- The operator needs `roles/container.admin` and `roles/iam.serviceAccountAdmin` (or equivalent) in that project.
- `gcp-network` creates a subnet per region in `subnet_cidrs`; add regions there if the cluster spans more than one.
- `data.google_client_config` reads the caller's ADC when planning, so run `gcloud auth application-default login` first.
