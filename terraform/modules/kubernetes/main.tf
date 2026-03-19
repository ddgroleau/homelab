locals {
  argocd_name  = "argocd"
  traefik_name = "traefik"
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = local.argocd_name
  }
}

resource "kubernetes_namespace_v1" "traefik" {
  metadata {
    name = local.traefik_name
  }
}

resource "kubernetes_namespace_v1" "metallb" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "argocd" {
  name       = local.argocd_name
  namespace  = local.argocd_name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.1.0"
}

resource "kubernetes_secret_v1" "tls" {
  metadata {
    name      = "local-selfsigned-tls"
    namespace = local.traefik_name
  }

  data = {
    "tls.crt" = var.tls_cert
    "tls.key" = var.tls_key
  }

  type = "kubernetes.io/tls"
}


