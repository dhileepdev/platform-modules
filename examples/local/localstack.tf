resource "docker_container" "localstack" {
  name  = "platform-local-localstack"
  image = "localstack/localstack:4.9.2"

  ports {
    internal = 4566
    external = 4566
  }
}
