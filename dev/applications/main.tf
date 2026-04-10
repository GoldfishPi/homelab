terraform {
  required_providers {
    openwrt = {
      source = "joneshf/openwrt"
      version = "0.0.20"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}

variable "host" {
  type = string
}

variable "client_key" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

variable "client_certificate" {
  type = string
}

provider "kubernetes" {
  host = "https://${var.host}:6443"
  client_key = var.client_key
  cluster_ca_certificate = var.cluster_ca_certificate
  client_certificate = var.client_certificate
}

provider "helm" {
  kubernetes = {
    host = "https://${var.host}:6443"
    client_key = var.client_key
    cluster_ca_certificate = var.cluster_ca_certificate
    client_certificate = var.client_certificate
  }
}

provider "kubectl" {
  host = "https://${var.host}:6443"
  client_key = var.client_key
  cluster_ca_certificate = var.cluster_ca_certificate
  client_certificate = var.client_certificate
  load_config_file       = false
}

module "immich" {
  source = "./immich/"
  host = var.host
  providers = {
    openwrt = openwrt
    kubernetes = kubernetes
    kubectl = kubectl
    helm = helm
  }
}
