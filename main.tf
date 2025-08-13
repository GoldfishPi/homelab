module "infrastructure" {
  source = "./infra/"
  providers = {
    proxmox = proxmox
  }
}

output "test" {
  value = module.infrastructure.test_debian_ipv4
}

output "postgres" {
  value = module.infrastructure.postgres_ipv4
}
