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

provider "pihole" {
  url      = "http://pihole.local" # PIHOLE_URL
  password = var.pihole_password
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

resource "cloudflare_dns_record" "test" {
  zone_id = "3832536fbbd4c141a963a3fd3f620f99"
  name = "test.erikbadger.com"
  ttl = 120
  type = "A"
  comment = "test record"
  content = "192.168.0.17"
  proxied = false
}
