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
