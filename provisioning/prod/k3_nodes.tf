
resource "proxmox_virtual_environment_vm" "k3s_nodes" {
  count = 3
  vm_id = proxmox_virtual_environment_vm.k3s_server.vm_id + 1 + count.index
  name      = "node${count.index + 1}.k3s.${var.namespace}"
  node_name = var.node
  tags = ["k3s","node"]

  # should be true if qemu agent is not installed / enabled on the VM
  stop_on_destroy = false

  agent {
    enabled = true
  }

  memory {
    dedicated = var.worker_memory
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

resource "ansible_playbook" "configure_k3s_nodes" {
  for_each = {
    for idx, vm in proxmox_virtual_environment_vm.k3s_nodes :
    idx => vm
  }
  playbook   = "${path.module}/playbooks/k3s_node.yaml"
  name       = each.value.ipv4_addresses[1][0]
  replayable = true

  extra_vars = {
    ansible_user                 = "erik"
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
    k3s_url = openwrt_dhcp_domain.k3s_server.name
    k3s_token = local.token
    node_name = each.value.name
  }

  depends_on = [
    proxmox_virtual_environment_vm.k3s_server,
    proxmox_virtual_environment_vm.k3s_nodes
  ]
}
