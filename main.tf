module "infrastructure" {
  source = "./infra/"
  providers = {
    proxmox = proxmox
  }
}

output "instance_ip_address" {
  value = module.infrastructure.instance_ip_address
}
