
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    pihole = {
      source  = "registry.terraform.io/lukaspustina/pihole"
      version = "0.3.0"
    }
  }
}
