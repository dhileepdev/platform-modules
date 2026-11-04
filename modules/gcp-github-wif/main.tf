locals {
  subjects = [
    for ref in var.allowed_refs : "repo:${var.github_org}/${var.github_repo}:ref:${ref}"
  ]

  attribute_condition = join(" || ", [
    for subject in local.subjects :
    strcontains(subject, "*")
    ? "assertion.sub.startsWith('${replace(subject, "*", "")}')"
    : "assertion.sub == '${subject}'"
  ])
}

resource "google_iam_workload_identity_pool" "this" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "${var.name_prefix} GitHub Actions pool"
}

resource "google_iam_workload_identity_pool_provider" "this" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "${var.name_prefix} GitHub OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = local.attribute_condition

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "this" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "${var.name_prefix} GitHub Actions deployer"
}

resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.this.name}/attribute.repository/${var.github_org}/${var.github_repo}"
}

resource "google_project_iam_member" "roles" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.this.email}"
}
