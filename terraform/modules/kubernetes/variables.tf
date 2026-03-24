variable "tls_cert" {
  description = "The self-signed local TLS Cert"
  type        = string
  sensitive   = true
}

variable "tls_key" {
  description = "The self-signed local TLS private key"
  type        = string
  sensitive   = true
}

variable "traefik_dashboard_username" {
  description = "The Traefik dashboard username"
  type        = string
  sensitive   = true
}

variable "traefik_dashboard_password" {
  description = "The Traefik dashboard password"
  type        = string
  sensitive   = true
}
