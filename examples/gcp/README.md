# GCP example

The network layer of this example runs against the Floci GCP emulator; the GKE and workload-identity layers have never been applied anywhere. `gcloud` is installed, but no GCP project or billing account was available. The configuration is complete; treat the cluster and identity parts as a reviewed starting point.

```bash
make up-gcp-emulated    # applies only module.network to Floci on :4588
make down-gcp-emulated
```

GKE creation against the emulator fails with `clusterId query parameter is required`, and service-account creation fails with `CREDENTIALS_MISSING`; that is why only the network is in the emulated target.

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
