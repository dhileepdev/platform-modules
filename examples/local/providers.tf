module "kind" {
  source = "../../modules/kind-cluster"

  name_prefix = "platform-local"
  node_count  = 1
}

provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
  config_context = module.kind.context
}
