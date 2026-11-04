resource "kubernetes_namespace_v1" "demo" {
  metadata {
    name = "demo"
  }

  depends_on = [module.kind]
}

module "observability" {
  source = "../../modules/observability"

  namespace = "monitoring"

  slos = [
    { name = "availability", target = 0.999, window = "28d" },
    { name = "latency", target = 0.99, window = "7d" },
  ]

  depends_on = [module.kind]
}

module "github_oidc" {
  source = "../../modules/aws-github-oidc"

  name_prefix  = "gha"
  github_org   = "dhileepdev"
  github_repo  = "secure-delivery"
  allowed_refs = ["refs/heads/main"]

  depends_on = [docker_container.floci]
}

resource "kubernetes_deployment_v1" "placeholder" {
  metadata {
    name      = "placeholder"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name

    labels = {
      app = "placeholder"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "placeholder"
      }
    }

    template {
      metadata {
        labels = {
          app = "placeholder"
        }
      }

      spec {
        container {
          name  = "placeholder"
          image = "nginxinc/nginx-unprivileged:1.27-alpine"

          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true

            capabilities {
              drop = ["ALL"]
            }
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }

          volume_mount {
            name       = "cache"
            mount_path = "/var/cache/nginx"
          }
        }

        security_context {
          run_as_non_root = true
        }

        volume {
          name = "tmp"

          empty_dir {}
        }

        volume {
          name = "cache"

          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "placeholder" {
  metadata {
    name      = "placeholder"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name
  }

  spec {
    selector = {
      app = "placeholder"
    }

    port {
      port        = 80
      target_port = 8080
    }
  }
}
