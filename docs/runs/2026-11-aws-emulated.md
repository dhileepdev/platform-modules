# Emulated AWS and GCP run — 2026-11-04

- Scope: `examples/aws` (network + GitHub OIDC) and `examples/gcp` (network) applied against Floci, not against a cloud account.
- Emulators: `floci/floci:2.4.0` on `:4567`, `floci/floci-gcp:0.12.0` on `:4588`.
- Cost: $0. No cloud credentials were used.

## Why not a real AWS account

The only available account (`612640997769`) has an SCP (`p-hwe3zqb7`) that denies `eks:ListClusters` in every region; `ap-south-1`, `us-east-1`, `us-west-2` and `eu-west-1` were all tested. A real EKS run cannot be created there, so the run was moved to Floci and the real runbook stays in `docs/runbooks/aws-demo.md` for an account that allows EKS.

## AWS: `make up-aws-emulated`

```console
$ time make up-aws-emulated
...
Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:

github_role_arn = "arn:aws:iam::000000000000:role/demo-github-actions"
vpc_id = "vpc-ad7d50c4"
real 6.33
```

Applied: VPC `10.42.0.0/16`, four `/24` subnets (two public, two private), one NAT gateway, internet gateway, route tables, a `/aws/vpc/demo-flow-logs` log group with flow log `fl-4e06f70a0daeea142`, the `demo-github-actions` role, and the GitHub OIDC provider.

Verification against the emulator (`aws --region ap-south-1 --endpoint-url http://localhost:4567`):

```text
vpc:      vpc-ad7d50c4
subnets:  10.42.0.0/24  10.42.1.0/24  10.42.2.0/24  10.42.3.0/24
nat:      nat-206b5e2d4bdaa975f  available
flow log: fl-4e06f70a0daeea142
role:     demo-github-actions
```

The role's trust policy is scoped, not wildcard:

```json
"StringLike": {
  "token.actions.githubusercontent.com:sub": [
    "repo:dhileepdev/secure-delivery:ref:refs/heads/main"
  ]
}
```

Before destroy, the verification script correctly reports what is still present:

```console
$ ./scripts/verify-no-aws-resources.sh demo ap-south-1 http://localhost:4567
STILL PRESENT: NAT gateways
nat-206b5e2d4bdaa975f
```

## AWS: destroy and prove clean

```console
$ time terraform -chdir=examples/aws destroy -auto-approve \
    -var aws_endpoint_url=http://localhost:4567 -var caller_cidr=203.0.113.10/32
Destroy complete! Resources: 25 destroyed.
real 28.31

$ ./scripts/verify-no-aws-resources.sh demo ap-south-1 http://localhost:4567
clean: no demo resources in ap-south-1
```

Elapsed from apply start (08:58:12 UTC) to clean (08:58:57 UTC): **45 seconds**, well inside the 60-minute ceiling.

## GCP: `make up-gcp-emulated`

```console
$ time make up-gcp-emulated
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
real 21.87
```

Applied: `demo-vpc`, the `demo-asia-south1` subnet in `10.10.0.0/20`, and the default-deny ingress firewall. Confirmed through the emulator's compute API:

```json
{"kind":"compute#networkList","items":[{"autoCreateSubnetworks":false,
"description":"Managed by platform-modules: demo","name":"demo-vpc",
"subnetworks":[".../regions/asia-south1/subnetworks/demo-asia-south1"]}]}
```

Destroy returned `Resources: 3 destroyed` in 1m39s (the network deletion polls for 10s at a time).

## What this run does and does not prove

Proved: both network modules and the AWS identity module produce the intended graph, validators and policies, and teardown removes everything.

Not proved: anything the emulators do not implement identically to the cloud. On GCP, `google_service_account` creation failed with `CREDENTIALS_MISSING` and GKE creation failed with `clusterId query parameter is required`, so the GCP identity and cluster modules remain mock-tested only (ADR 0003). EKS was not applied; the emulator's EKS needs the Docker socket and a real IAM user for cluster admin, which is outside this run's scope.

Timings are emulator timings and are not a forecast of cloud apply time.
