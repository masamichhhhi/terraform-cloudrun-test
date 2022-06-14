terraform {
  required_version = "~> 1.2.2"
  backend "gcs" {
    prefix = "terraform/state"
  }
}

locals {
  cloudrun_roles = [
    "roles/run.developer",
    "roles/iam.serviceAccountUser",
  ]
}

resource "google_project_service" "default" {
  project = var.project
  service = "iamcredentials.googleapis.com"
}

resource "google_service_account" "github_actions" {
  project      = var.project
  account_id   = "github-actions"
  display_name = "A service account for GitHub Actions"
  description  = "link to Workload Identity Pool used by GitHub Actions"
}

resource "google_iam_workload_identity_pool" "github" {
  provider                  = google-beta
  project                   = var.project
  workload_identity_pool_id = "github"
  display_name              = "github"
  description               = "A Workload Identity Pool used by GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  provider                           = google-beta
  project                            = var.project
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "github actions provider"
  description                        = "OIDC identity pool provider for executing GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repositoty" = "assertion.repository"
    "attribute.owner"      = "assertion.repository_owner"
    "attribute.refs"       = "assertion.ref"
  }

  oidc {
    issuer_uri = "https://token.actions.githubsercontent.com"
  }
}

resource "google_service_account_iam_member" "github-account-iam" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.repo_name}"
}

resource "google_project_iam_member" "service_account" {
  count   = length(local.cloudrun_roles)
  project = var.project
  role    = element(local.cloudrun_roles, count.index)
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

output "service_account_github_actions_email" {
  description = "github account for github actions"
  value       = google_service_account.github_actions.email
}

output "google_iam_workload_identity_pool_provider_github_name" {
  description = "Workload Identity Pool Provider ID"
  value       = google_iam_workload_identity_pool_provider.github.name
}
