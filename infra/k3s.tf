resource "proxmox_virtual_environment_vm" "k3s_server" {
  vm_id = 3000
  name      = "server.k3s.homelab.lan"
  node_name = "node1"
  tags = ["k3s", "2GB"]

  # should be true if qemu agent is not installed / enabled on the VM
  stop_on_destroy = false

  agent {
    enabled = true
  }

  memory {
    dedicated = 2048
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
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  cpu {
    type = "host"
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.debian_cloud_image.id
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
  playbook   = "playbooks/k3s_server.yaml"
  name       = proxmox_virtual_environment_vm.k3s_server.ipv4_addresses[1][0]
  replayable = false

  extra_vars = {
    ansible_user                 = "erik"
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
    host_ip       = proxmox_virtual_environment_vm.k3s_server.ipv4_addresses[1][0]
  }

  depends_on = [proxmox_virtual_environment_vm.k3s_server]

}

resource "openwrt_dhcp_domain" "k3s_server" {
  id   = "k3s_server"
  ip   = proxmox_virtual_environment_vm.k3s_server.ipv4_addresses[1][0]
  name = "server.k3s.homelab.lan"
}

locals {
  token = regex(
    "K3S_SERVER_NODE_TOKEN=(.+)\"",
    ansible_playbook.configure_k3s_server.ansible_playbook_stdout
  )[0]
}

output "k3s_token" {
  value = local.token
}

resource "proxmox_virtual_environment_vm" "k3s_nodes" {
  count = 3
  vm_id = 3001 + count.index
  name      = "agent${count.index + 1}.k3s.homelab.lan"
  node_name = "node1"
  tags = ["k3s", "2GB"]

  # should be true if qemu agent is not installed / enabled on the VM
  stop_on_destroy = false

  agent {
    enabled = true
  }

  memory {
    dedicated = 2048
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
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  cpu {
    type = "host"
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.debian_cloud_image.id
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

locals {
  k3s_ip_list = [
    for vm in proxmox_virtual_environment_vm.k3s_nodes :
    vm.ipv4_addresses[1][0]
  ]
}

output "ips" {
  value = local.k3s_ip_list
}

resource "ansible_playbook" "configure_k3s_nodes" {
  for_each = toset(local.k3s_ip_list)
  playbook   = "playbooks/k3s_agent.yaml"
  name       = each.value
  replayable = false

  extra_vars = {
    ansible_user                 = "erik"
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
    k3s_url = openwrt_dhcp_domain.k3s_server.name
    k3s_token = local.token
    node_name = each.value
  }

  depends_on = [
    proxmox_virtual_environment_vm.k3s_server,
    proxmox_virtual_environment_vm.k3s_nodes
  ]
}
