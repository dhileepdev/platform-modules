resource "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  tags = {
    Name = "${var.name_prefix}-github-oidc"
  }
}

data "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 0 : 1

  url = "https://token.actions.githubusercontent.com"
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : data.aws_iam_openid_connect_provider.this[0].arn

  subjects = [
    for ref in var.allowed_refs : "repo:${var.github_org}/${var.github_repo}:ref:${ref}"
  ]

  trust_policy_json = templatefile("${path.module}/templates/trust-policy.json.tftpl", {
    oidc_provider_arn = local.oidc_provider_arn
    subjects          = jsonencode(local.subjects)
  })
}

resource "aws_iam_role" "this" {
  name                 = "${var.name_prefix}-github-actions"
  max_session_duration = var.max_session_duration
  assume_role_policy   = local.trust_policy_json

  tags = {
    Name = "${var.name_prefix}-github-actions"
  }
}

resource "aws_iam_role_policy" "caller_identity" {
  count = length(var.managed_policy_arns) == 0 ? 1 : 0

  name = "${var.name_prefix}-github-actions-caller-identity"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:GetCallerIdentity"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}
