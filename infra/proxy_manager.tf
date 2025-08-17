
resource "proxmox_virtual_environment_vm" "nginx_proxy_manager" {
  name      = "nginx-proxy-manager"
  node_name = "node1"

  # should be true if qemu agent is not installed / enabled on the VM
  stop_on_destroy = false

  agent {
    enabled = true
  }

  memory {
    dedicated = 4096
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
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }
  serial_device {
    device = "socket"
  }
  # provisioner "local-exec" {
  #   command = "ansible-playbook -i '${self.ipv4_addresses[1][0]},' playbooks/postgres.yaml"
  # }
}
