
terraform  {
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
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
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

module "cluster" {
  source = "./infra/"
  id_start = var.id_start
  namespace = var.namespace
  node = var.node
  providers = {
    proxmox = proxmox
    openwrt = openwrt
  }
}

module "applications" {
  source = "./applications/"
  host = module.cluster.k8s_server_ip
  client_key = base64decode(module.cluster.k8s_client_key)
  cluster_ca_certificate = base64decode(module.cluster.k8s_ca_certificate)
  client_certificate = base64decode(module.cluster.k8s_client_certificate)
  providers = {
    openwrt = openwrt
  }
}
