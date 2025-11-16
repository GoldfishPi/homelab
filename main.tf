module "infrastructure" {
  source = "./infra/"
  providers = {
    proxmox = proxmox
    openwrt = openwrt
  }
}
