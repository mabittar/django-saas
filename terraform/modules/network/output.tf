output "network_name" {
  description = "The name of the Docker network"
  value       = docker_network.my_app_network.name
}
