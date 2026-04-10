
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

variable "id_start" {
  type = number
}

variable "namespace" {
  type = string
}

variable "node" {
  type = string
}

variable "worker_memory" {
  type = number
  default = 4096
}

variable "server_memory" {
  type = number
  default = 4096
}

data "local_file" "ssh_public_key" {
  filename = "~/.ssh/id_rsa.pub"
}


resource "proxmox_download_file" "debian_cloud_image" {
  content_type       = "import"
  datastore_id       = "local"
  file_name          = "debian-12-genericcloud-amd64.qcow2"
  node_name          = var.node
  url                = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node

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
