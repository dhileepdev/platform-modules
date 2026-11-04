resource "docker_container" "floci" {
  name  = "platform-local-floci"
  image = "floci/floci:2.4.0"

  ports {
    internal = 4566
    external = 4566
  }
}
