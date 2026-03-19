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
