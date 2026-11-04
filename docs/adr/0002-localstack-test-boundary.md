# ADR 0002: LocalStack boundary for the local example

- Status: accepted
- Date: 2026-11-04

## Context

`examples/local` must prove the AWS identity module (`modules/aws-github-oidc`) without cloud credentials. LocalStack community is the default runtime, so the question was which AWS APIs it actually emulates for this module.

## Spike result

Image `localstack/localstack:4.9.2` (community, no auth token):

```console
$ awslocal iam create-open-id-connect-provider \
    --url https://token.actions.githubusercontent.com \
    --client-id-list sts.amazonaws.com
{
    "OpenIDConnectProviderArn": "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com"
}
```

`list-open-id-connect-providers` confirms the provider, and `iam create-role` / `get-role` accept a trust policy that references it. The role, the trust policy and the inline `sts:GetCallerIdentity` policy are therefore applied for real against LocalStack.

`localstack/localstack:latest` (2026.10.5) refuses to start without a `LOCALSTACK_AUTH_TOKEN`; the local example pins `4.9.2` instead of `latest` so `make up` stays free and offline.

## Boundary

- Verified locally: IAM OIDC provider creation, role creation, trust-policy storage, inline policy, managed-policy attachment.
- Verified automatically: the rendered trust policy (subject scoping, `StringLike`, no bare wildcard) through `terraform test` with `mock_provider`.
- Not verified locally: GitHub actually exchanging a token for credentials, and any downstream service the role would call. LocalStack accepts any well-formed web identity token; it does not validate GitHub's signature or the `sub` claim against a real token.
- Real-cloud run: the same module is applied to one real AWS account in the timeboxed run recorded in `docs/runbooks/`.

## Consequences

- `make up` needs Docker, not AWS credentials.
- A trust-policy regression is caught by the module test; a LocalStack pass alone is not evidence that GitHub federation works in a real account.
