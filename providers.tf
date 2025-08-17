terraform {
  required_version = ">= 1.12.1"
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = ">= 0.81.0"
    }
    pihole = {
      source  = "registry.terraform.io/lukaspustina/pihole"
      version = "0.3.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.host
  username = var.username
  password = var.password
  insecure = true
}

provider "pihole" {
  url      = "http://pihole.local" # PIHOLE_URL
  password = var.pihole_password
}
