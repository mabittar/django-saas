output "app_container_ids" {
  description = "IDs of the application container"
  value       = [docker_container.application.*.id]
}

output "app_image_id" {
  description = "ID of the application image"
  value       = docker_image.application.id
}