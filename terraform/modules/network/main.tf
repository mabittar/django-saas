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

resource "docker_network" "my_app_network" {
  name = var.network_name
}