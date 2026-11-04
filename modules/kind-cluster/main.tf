locals {
  cluster_name = var.name_prefix
  config_path  = "${path.module}/.generated/kind-config.yaml"
}

resource "terraform_data" "cluster" {
  triggers_replace = [
    local.cluster_name,
    var.node_count,
    filemd5("${path.module}/scripts/kind-up.sh"),
  ]

  provisioner "local-exec" {
    command = "${path.module}/scripts/kind-up.sh ${local.cluster_name} ${var.node_count} ${local.config_path}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/scripts/kind-down.sh ${self.triggers_replace[0]}"
  }
}
