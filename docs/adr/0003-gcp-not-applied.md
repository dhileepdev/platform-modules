# ADR 0003: GCP is mock-tested, network emulated

- Status: accepted
- Date: 2026-11-04

## Context

The GCP modules (`gcp-network`, `gke-cluster`, `gcp-github-wif`) exist to show multi-cloud module design. The build machine has `gcloud` installed but no GCP account, project or billing relationship was available, and the 60-minute real-cloud budget was reserved for AWS.

## Decision

- GCP modules ship with `terraform test` suites using `mock_provider`.
- `gcp-network` is additionally applied against the Floci GCP emulator (`make up-gcp-emulated`), which covers the compute API only.
- `gke-cluster` and `gcp-github-wif` have never been applied, not even against the emulator: GKE creation fails with `clusterId query parameter is required` and service-account creation fails with `CREDENTIALS_MISSING`. They stay mock-tested.
- No real GCP project has been used.
- CI runs `validate` for the example and `test` for the modules; it never runs `apply` for GCP.
- The limitation is stated in the first paragraph of `examples/gcp/README.md` and in the root README's test matrix.

## Consequences

- Reviewers get working, typed, validated GCP configuration without a cloud bill.
- Mock tests and the emulated network apply prove naming, validation and wiring; they do not prove that a real project accepts the GKE and WIF graph. Treat those two modules as a reviewed starting point.
- The same WIF output shape is consumed by `secure-delivery`'s GCP path, so a wrong shape is caught in that repo's tests even without applying here.
