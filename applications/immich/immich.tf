
terraform {
  required_providers {
    openwrt = {
      source = "joneshf/openwrt"
      version = "0.0.20"
    }
  }
}

resource "kubernetes_namespace" "immich" {
  metadata {
    name = "immich"
  }
}

resource "ku"
