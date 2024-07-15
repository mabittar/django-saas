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

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx_server" {
  image = docker_image.nginx.image_id
  count = 2
  name  = "nginx_server-${count.index + 1}"
  ports {
    internal = 80
    external = "808${count.index + 1}"
  }
  volumes {
    container_path = "/etc/nginx/conf.d/default.conf"
    host_path      = abspath("${path.module}/nginx.conf")
  }
  networks_advanced {
    name = var.network_name
  }
  command = ["nginx", "-g", "daemon off;"]

}


