terraform {
  required_providers {
    openwrt = {
      source = "joneshf/openwrt"
      version = "0.0.20"
    }
  }
}

module "immich" {
  source = "./immich/"
  providers = {
    openwrt = openwrt
    kubernetes = kubernetes
  }
}
