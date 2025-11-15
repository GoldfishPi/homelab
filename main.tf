module "infrastructure" {
  source = "./infra/"
  providers = {
    proxmox = proxmox
    # pihole = pihole
    # npm = npm
  }
}

# output "postgres" {
#   value = module.infrastructure.postgres_local
# }

# TODO: Move these to a real place lol
# resource "pihole_dns_record" "nas" {
#   domain = "truenas.local"
#   ip     = "192.168.0.66"
# }
