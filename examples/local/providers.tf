module "kind" {
  source = "../../modules/kind-cluster"

  name_prefix = "platform-local"
  node_count  = 1
}

provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
  config_context = module.kind.context
}

provider "helm" {
  kubernetes = {
    config_path    = pathexpand("~/.kube/config")
    config_context = module.kind.context
  }
}

# Floci stands in for IAM and STS only. Credentials are the documented
# Floci dummy values, never real ones.
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}
