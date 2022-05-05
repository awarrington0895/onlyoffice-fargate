variable "amqp_username" {
  type        = string
  description = "Username for authenticating to message broker"
}

variable "amqp_password" {
  type        = string
  sensitive   = true
  description = "Password for authenticating to message broker"
}

variable "amqp_host" {
  type        = string
  description = "Endpoint for accessing message broker"
}