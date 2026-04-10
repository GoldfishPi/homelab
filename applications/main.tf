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
