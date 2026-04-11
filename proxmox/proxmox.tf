
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

variable "host" {
  type = string
  description = "Proxmox host"
}

variable "username" {
  type = string
  description = "Proxmox PAM username"
}

variable "password" {
  type = string
  description = "Proxmox PAM password"
}

variable "nodes" {
  type = set(string)
  description = "List of proxmox nodes that need to be configured"
  default = ["node1", "node2", "node3"]
}

provider "proxmox" {
  endpoint = var.host
  username = var.username
  password = var.password
  insecure = true
}

resource "proxmox_download_file" "debian_cloud_image" {
  content_type       = "import"
  datastore_id       = "nfs"
  file_name          = "debian-12-genericcloud-amd64.qcow2"
  node_name          = "node1"
  url                = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  # for_each = var.nodes
  content_type = "snippets"
  datastore_id = "nfs"
  node_name    = "node1"

  source_raw {
    data = <<-EOF
    #cloud-config
    users:
      - default
      - name: erik
        ssh_authorized_keys:
          - ${trimspace(file("~/.ssh/id_rsa.pub"))}
        groups:
          - sudo
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL

    package_update: true
    package_upgrade: true

    packages:
      - qemu-guest-agent
      - net-tools


    bootcmd:
      - /bin/bash -c "until ping -c1 8.8.8.8; do sleep 2; done"

    runcmd:
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cloud-config.yaml"
  }
}


output "cloud_config_id" {
  value = proxmox_virtual_environment_file.cloud_config.id
}

output "debian_cloud_image_id" {
  value = proxmox_download_file.debian_cloud_image.id
}
