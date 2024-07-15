output "nginx_container_ids" {
  description = "IDs of the nginx_server container"
  value       = [docker_container.nginx_server.*.id]
}

output "nginx_image_id" {
  description = "ID of the Nginx image"
  value       = docker_image.nginx.id
}

# output "nginx_container_access_url" {
#   description = "Url to access nginx services"
#   value       = [docker_container.nginx_server.*.host_path]
# }