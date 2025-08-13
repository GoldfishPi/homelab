data "local_file" "ssh_public_key" {
  filename = "id_rsa.pub"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "node1"

  source_raw {
    data = <<-EOF
    #cloud-config
    users:
      - default
      - name: erik
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        groups:
          - sudo
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - apt update
        - apt install -y qemu-guest-agent net-tools
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "node1"
  url          = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "debian-12-genericcloud-amd64.qcow2"
  overwrite = true
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name      = "test-ubuntu"
  node_name = "node1"

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
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
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
}

output "instance_ip_address" {
  value = proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses[1][0]
}
