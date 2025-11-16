resource "proxmox_virtual_environment_vm" "jumpbox" {
  vm_id = 2000
  name      = "jumpbox"
  node_name = "node1"
  tags = ["k8s"]

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

resource "openwrt_dhcp_domain" "jumpbox" {
  id   = "jumpbox"
  ip   = proxmox_virtual_environment_vm.jumpbox.ipv4_addresses[1][0]
  name = "jumpbox.ks.local"
}

resource "proxmox_virtual_environment_vm" "server" {
  vm_id = 2001
  name      = "server"
  node_name = "node1"
  tags = ["k8s"]

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

resource "openwrt_dhcp_domain" "server" {
  id   = "server"
  ip   = proxmox_virtual_environment_vm.server.ipv4_addresses[1][0]
  name = "server.ks.local"
}

resource "proxmox_virtual_environment_vm" "node-0" {
  vm_id = 2002
  name      = "node-0"
  node_name = "node1"
  tags = ["k8s"]

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

resource "openwrt_dhcp_domain" "node-0" {
  id   = "node0"
  ip   = proxmox_virtual_environment_vm.node-0.ipv4_addresses[1][0]
  name = "node0.ks.local"
}

resource "proxmox_virtual_environment_vm" "node-1" {
  vm_id = 2003
  name      = "node-1"
  node_name = "node1"
  tags = ["k8s"]

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

resource "openwrt_dhcp_domain" "node-1" {
  id   = "node1"
  ip   = proxmox_virtual_environment_vm.node-1.ipv4_addresses[1][0]
  name = "node1.ks.local"
}
