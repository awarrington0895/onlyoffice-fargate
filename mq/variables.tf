variable "username" {
  type        = string
  description = "Username for broker"
}

variable "password" {
  type        = string
  sensitive   = true
  description = "Password for broker"
}