module "infrastructure" {
  source = "./infra/"
  providers = {
    proxmox = proxmox
    openwrt = openwrt
  }
}


provider "kubernetes" {
  host = "https://${module.infrastructure.k8s_server_ip}:6443"
  client_key = base64decode(module.infrastructure.k8s_client_key)
  cluster_ca_certificate = base64decode(module.infrastructure.k8s_ca_certificate)
  client_certificate = base64decode(module.infrastructure.k8s_client_certificate)
}

module "applications" {
  source = "./applications/"
  providers = {
    openwrt = openwrt
    kubernetes = kubernetes
  }
}
