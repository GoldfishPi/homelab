
resource "proxmox_virtual_environment_vm" "k3s_server" {
  vm_id = var.id_start
  name      = "server.k3s.${var.namespace}"
  node_name = var.node
  tags = ["k3s","server"]

  # should be true if qemu agent is not installed / enabled on the VM
  stop_on_destroy = false

  agent {
    enabled = true
  }

  memory {
    dedicated = var.server_memory
  }

  operating_system {
    type = "l26"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = local.cloud_config_id
  }

  cpu {
    type = "host"
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = local.debian_cloud_image_id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 200
  }

  network_device {
    bridge = "vmbr0"
  }
  serial_device {
    device = "socket"
  }
}

resource "ansible_playbook" "configure_k3s_server" {
  playbook   = "${path.module}/playbooks/k3s_server.yaml"
  name       = proxmox_virtual_environment_vm.k3s_server.ipv4_addresses[1][0]
  replayable = true

  extra_vars = {
    ansible_user                 = "erik"
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
    host_ip       = proxmox_virtual_environment_vm.k3s_server.ipv4_addresses[1][0]
  }

  depends_on = [proxmox_virtual_environment_vm.k3s_server]

}

resource "openwrt_dhcp_domain" "k3s_server" {
  id   = proxmox_virtual_environment_vm.k3s_server.id
  ip   = proxmox_virtual_environment_vm.k3s_server.ipv4_addresses[1][0]
  name = proxmox_virtual_environment_vm.k3s_server.name
}

locals {
  token = regex(
    "K3S_SERVER_NODE_TOKEN=(.+)\"",
    ansible_playbook.configure_k3s_server.ansible_playbook_stdout
  )[0]
}

output "k3s_server" {
  value = openwrt_dhcp_domain.k3s_server.name
}
