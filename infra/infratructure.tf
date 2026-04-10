
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    openwrt = {
      source = "joneshf/openwrt"
      version = "0.0.20"
    }
    ansible = {
      version = "~> 1.4.0"
      source  = "ansible/ansible"
    }
  }
}

data "local_file" "ssh_public_key" {
  filename = "id_rsa.pub"
}
