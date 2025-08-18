module "infrastructure" {
  source = "./infra/"
  providers = {
    proxmox = proxmox
    pihole = pihole
    # npm = npm
  }
}

output "postgres" {
  value = module.infrastructure.postgres_local
}
