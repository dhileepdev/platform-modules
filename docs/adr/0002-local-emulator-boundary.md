# ADR 0002: Local emulator boundary

- Status: accepted
- Date: 2026-11-04 (supersedes the LocalStack version of this ADR)

## Context

The examples must prove modules without cloud credentials, and the real AWS run is blocked by account policy. The emulator choice is therefore part of the contract: which APIs are real, which are mocked, and what a green local run is allowed to claim.

Floci (`floci/floci`) is a free, MIT-licensed AWS emulator on `:4566`, a drop-in replacement for LocalStack with no auth token and no feature gates. A companion `floci/floci-gcp` emulates GCP on `:4588`.

## Spike results

AWS, image `floci/floci:2.4.0`:

```console
$ AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test \
    aws --endpoint-url http://localhost:4566 iam create-open-id-connect-provider \
    --url https://token.actions.githubusercontent.com \
    --client-id-list sts.amazonaws.com
{
    "OpenIDConnectProviderArn": "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com"
}
```

`iam create-role` and `get-role` then accept a trust policy that references that provider and return it verbatim, so the role, trust policy and inline policy in `modules/aws-github-oidc` are applied against Floci, not mocked.

The LocalStack versions previously used here (`localstack/localstack:4.9.2`) worked for the same IAM calls, but `latest` (2026.10.5) now exits without a `LOCALSTACK_AUTH_TOKEN`, and EKS and VPC are Pro-gated. Floci removes both problems.

## Boundary

- Applied locally: IAM OIDC provider, role, trust policy, inline policy; VPC and EKS resources where the emulated API supports them; the kind cluster and kube-prometheus-stack for real.
- Asserted by `terraform test`: rendered trust policy (subject scoping, `StringLike`, no bare wildcard), CIDR math, SLO rule rendering.
- Not proven by any local run: GitHub exchanging a token for credentials, GitHub's signature on the `sub` claim, and real AWS behaviour where the emulator differs (quotas, eventual consistency, IAM evaluation of every downstream action).
- The GCP emulator is used for the network layer only; GKE emulation is documented but not applied. See [ADR 0003](0003-gcp-not-applied.md).

## Consequences

- `make up` needs Docker, not cloud credentials, and leaves no paid resources.
- A green local run is evidence that the Terraform graph and policies are right, not that the cloud accepts them. Real-cloud behaviour stays a separate, timeboxed check.
