module "infrastructure" {
  source = "./infra/"
  providers = {
    proxmox = proxmox
    pihole = pihole
  }
}

output "postgres" {
  value = module.infrastructure.postgres_local
}
