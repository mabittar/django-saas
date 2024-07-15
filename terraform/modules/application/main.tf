terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host  = "unix:///var/run/docker.sock"
}

resource "docker_image" "application" {
  name = "application:latest"
  build {
    context    = "${path.root}/../src"
    dockerfile = "Dockerfile"
  }
  keep_locally = false
}

resource "docker_container" "application" {
  image = docker_image.application.image_id
  name  = var.app_name
  # env   = ["PORT=${var.application_server_port}"]
  ports {
    internal = var.application_server_port
    external = var.application_server_port
  }
  networks_advanced {
    name = var.network_name
  }
}