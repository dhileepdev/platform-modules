mock_provider "aws" {
  mock_resource "aws_iam_openid_connect_provider" {
    defaults = {
      arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
    }
    override_during = plan
  }
}

run "trust_policy_is_ref_scoped" {
  command = plan
  variables {
    name_prefix  = "gha"
    github_org   = "dhileepdev"
    github_repo  = "secure-delivery"
    allowed_refs = ["refs/heads/main", "refs/tags/v*"]
  }
  assert {
    condition     = strcontains(output.trust_policy_json, "repo:dhileepdev/secure-delivery:ref:refs/heads/main")
    error_message = "branch subject must be org/repo scoped"
  }
  assert {
    condition     = strcontains(output.trust_policy_json, "StringLike")
    error_message = "tag patterns need StringLike"
  }
  assert {
    condition     = !strcontains(output.trust_policy_json, "\"*\"")
    error_message = "no wildcard subject"
  }
}

run "rejects_empty_refs" {
  command = plan
  variables {
    name_prefix  = "gha"
    github_org   = "dhileepdev"
    github_repo  = "secure-delivery"
    allowed_refs = []
  }
  expect_failures = [var.allowed_refs]
}

run "rejects_wildcard_ref" {
  command = plan
  variables {
    name_prefix  = "gha"
    github_org   = "dhileepdev"
    github_repo  = "secure-delivery"
    allowed_refs = ["*"]
  }
  expect_failures = [var.allowed_refs]
}

run "rejects_branch_namespace_wildcard" {
  command = plan
  variables {
    name_prefix  = "gha"
    github_org   = "dhileepdev"
    github_repo  = "secure-delivery"
    allowed_refs = ["refs/heads/*"]
  }
  expect_failures = [var.allowed_refs]
}
