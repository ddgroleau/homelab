variable "kube_config" {
  description = "The KUBE_CONFIG path"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "The name of the Kubernetes context to use"
  type        = string
  default     = "kubernetes-admin@kubernetes"
}

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
