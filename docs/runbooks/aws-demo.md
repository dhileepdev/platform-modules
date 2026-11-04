# AWS demo runbook

One timeboxed run against a real account. Ceiling: **60 minutes** from first apply to "destroy complete", with **25 minutes** budgeted for the apply itself. If the clock is exceeded, destroy first and record the failure.

## Pre-flight (about 5 minutes)

```bash
export AWS_PROFILE=<profile>
export TF_VAR_caller_cidr="$(curl -s https://ifconfig.me)/32"

aws sts get-caller-identity
aws configure get region
terraform -chdir=examples/aws init -upgrade -input=false
terraform -chdir=examples/aws validate
```

- Confirm the account is a sandbox or otherwise expendable.
- Confirm no `demo-*` resources already exist: `./scripts/verify-no-aws-resources.sh demo ap-south-1`.
- Set a timer. All commands below are run from the repo root.

## Apply (ceiling 25 minutes)

The observability module is wired to the EKS cluster through module outputs, so the first apply cannot create the Helm release before the cluster exists. Apply in two stages:

```bash
time terraform -chdir=examples/aws apply -auto-approve -target=module.eks
time terraform -chdir=examples/aws apply -auto-approve
```

Expected: one VPC, two private and two public subnets, one NAT gateway, one EKS 1.33 cluster, two `t3.small` nodes, one GitHub OIDC provider and role, kube-prometheus-stack in `monitoring`.

The apply is the long step (roughly 20–25 minutes, an estimate not yet measured against a real account). If it has not finished at 25 minutes, press on to the demo only if the cluster is healthy; otherwise destroy.

The two-stage apply above is the ceiling on a single run: the first targeted apply creates the EKS cluster, the second creates the OIDC role, the load-generator/observability wiring and everything that depends on cluster outputs.

## Demo (about 10 minutes)

```bash
aws eks update-kubeconfig --name demo --region ap-south-1
kubectl get nodes
kubectl -n monitoring get pods
kubectl -n monitoring get prometheusrule | grep slo-

aws iam get-role --role-name demo-github-actions \
  --query 'Role.AssumeRolePolicyDocument' --output json

aws eks describe-cluster --name demo \
  --query 'cluster.identity.oidc.issuer' --output text
```

Talking points:

1. Every module took cloud, region and account as inputs; nothing is hardcoded.
2. The trust policy is scoped to `repo:dhileepdev/secure-delivery:ref:refs/heads/main` — no wildcard subject.
3. The EKS API allowlist is the operator's `/32`, not `0.0.0.0/0`.
4. SLO rules are generated from variables and present in Prometheus.

## Destroy (hard stop at 60 minutes)

```bash
time terraform -chdir=examples/aws destroy -auto-approve
./scripts/verify-no-aws-resources.sh demo ap-south-1
```

Expected: destroy completes, then `clean: no demo resources in ap-south-1`.

If `destroy` fails:

```bash
# Remaining node groups block cluster deletion; retry after they drain.
aws eks list-nodegroups --cluster-name demo --region ap-south-1
terraform -chdir=examples/aws destroy -auto-approve -refresh=true
```

If resources still exist, delete them by hand and record what was leaked in the run record. A leaked NAT gateway costs about $0.045/hour; an EKS cluster about $0.10/hour.

## Record

Create `docs/runbooks/aws-demo-<date>.md` with:

- account ID (or "redacted") and region,
- apply duration and destroy duration,
- command output for the four demo checks,
- the `verify-no-aws-resources.sh` result,
- anything that failed and how it was resolved.

No credentials, no full ARNs beyond what the demo output already shows.
