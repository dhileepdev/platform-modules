# ADR 0003: GCP is mock-tested, never applied

- Status: accepted
- Date: 2026-11-04

## Context

The GCP modules (`gcp-network`, `gke-cluster`, `gcp-github-wif`) exist to show multi-cloud module design. The build machine has `gcloud` installed but no GCP account, project or billing relationship was available, and the 60-minute real-cloud budget was reserved for AWS.

## Decision

- GCP modules ship with `terraform test` suites using `mock_provider`.
- `examples/gcp` is complete and `terraform validate`-clean but has never been planned or applied against a project.
- CI runs `validate` for the example and `test` for the modules; it never runs `apply` for GCP.
- The limitation is stated in the first paragraph of `examples/gcp/README.md` and in the root README's test matrix.

## Consequences

- Reviewers get working, typed, validated GCP configuration without a cloud bill.
- Mock tests prove naming, validation and wiring; they do not prove that the provider accepts the resource graph in a real project. Treat `examples/gcp` as a reviewed starting point.
- The same WIF output shape is consumed by `secure-delivery`'s GCP path, so a wrong shape is caught in that repo's tests even without applying here.
