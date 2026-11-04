provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "platform-modules"
      ManagedBy = "terraform"
      Demo      = "timeboxed"
    }
  }
}

module "network" {
  source = "../../modules/aws-network"

  name_prefix = var.name_prefix
  vpc_cidr    = var.vpc_cidr
  az_count    = 2
}

module "eks" {
  source = "../../modules/eks-cluster"

  name_prefix            = var.name_prefix
  cluster_version        = "1.33"
  subnet_ids             = module.network.private_subnet_ids
  node_desired_size      = 2
  endpoint_public_access = true
  public_access_cidrs    = [var.caller_cidr]
}

module "github_oidc" {
  source = "../../modules/aws-github-oidc"

  name_prefix  = var.name_prefix
  github_org   = "dhileepdev"
  github_repo  = "secure-delivery"
  allowed_refs = ["refs/heads/main"]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}

module "observability" {
  source = "../../modules/observability"

  namespace = "monitoring"
  slos = [
    { name = "availability", target = 0.999, window = "28d" },
  ]

  depends_on = [module.eks]
}
