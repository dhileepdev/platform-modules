provider "google" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source = "../../modules/gcp-network"

  name_prefix  = var.name_prefix
  project_id   = var.project_id
  subnet_cidrs = { (var.region) = var.subnet_cidr }
}

module "gke" {
  source = "../../modules/gke-cluster"

  name_prefix   = var.name_prefix
  project_id    = var.project_id
  region        = var.region
  network_id    = module.network.network_id
  subnetwork_id = module.network.subnet_ids[var.region]
}

module "github_wif" {
  source = "../../modules/gcp-github-wif"

  name_prefix  = var.name_prefix
  project_id   = var.project_id
  github_org   = var.github_org
  github_repo  = var.github_repo
  allowed_refs = ["refs/heads/main"]
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${module.gke.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

module "observability" {
  source = "../../modules/observability"

  namespace = "monitoring"

  depends_on = [module.gke]
}
