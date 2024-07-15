variable "app_name" {
  description = "Value of the name for the Docker application"
  type        = string
  default     = "Application"
}


variable "application_tag" {
  description = "Value of the tag for the Docker build"
  type        = number
  default     = 1
}


variable "application_server_port" {
  description = "Value of the application running port"
  type        = number
  default     = 8000
}


variable "network_name" {
  type = string
}

