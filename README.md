# platform-modules

Reusable Terraform modules for AWS and GCP platforms. Every module takes cloud, region, account, and naming inputs — there are no account IDs, regions, or ARNs inside `modules/`.

Status: `v0.1.0` in progress. Modules land with tests as they are added; the root README keeps the full matrix once the local example is complete.

## Modules

| Module | Cloud | What it creates |
| --- | --- | --- |
| [`aws-network`](modules/aws-network) | AWS | VPC, public and private `/24` subnets, NAT gateway(s), route tables, optional flow logs |

## Use a module

```hcl
module "network" {
  source = "git::https://github.com/dhileepdev/platform-modules.git//modules/aws-network?ref=v0.1.0"

  name_prefix = "payments"
  vpc_cidr    = "10.20.0.0/16"
  az_count    = 2
}
```

## Local demo

`make up` creates the kind + LocalStack environment; `make down` removes it. Requires Docker, kind, kubectl, and Terraform. Nothing in the local path needs cloud credentials.

## Test

```bash
make test
```

Runs `terraform test` for every module with mocked providers and no credentials.

## Conventions

- `name_prefix` matches `^[a-z][a-z0-9-]{1,20}$`.
- Inputs are validated at the boundary; a wrong CIDR or an unsafe default fails at plan time.
- Modules never set a provider or a backend. The caller owns both.
- New behaviour arrives with a test that failed first.

## License

Apache-2.0. See [LICENSE](LICENSE).
