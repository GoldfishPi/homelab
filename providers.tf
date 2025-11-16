terraform {
  required_version = ">= 1.12.1"
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = ">= 0.86.0"
    }
    openwrt = {
      source = "joneshf/openwrt"
      version = "0.0.20"
    }
    nginxproxymanager = {
      source = "Sander0542/nginxproxymanager"
      version = "1.2.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "proxmox" {
  endpoint = var.host
  username = var.username
  password = var.password
  insecure = true
}

provider "nginxproxymanager" {
  url      = "https://proxy.lab.erikbadger.com/"
  username = var.pm_username
  password = var.pm_password
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "openwrt" {
  password = var.openwrt_password
}
