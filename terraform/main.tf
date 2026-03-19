terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

  }

  required_version = "~> 1.14.6"
}

provider "kubernetes" {
  config_path    = var.kube_config
  config_context = var.kube_context
}

provider "helm" {
  kubernetes = {
    config_path    = var.kube_config
    config_context = var.kube_context
  }

}

module "kubernetes" {
  source   = "./modules/kubernetes"
  tls_cert = var.tls_cert
  tls_key  = var.tls_key
}
