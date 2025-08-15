resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "node1"
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "debian-12-genericcloud-amd64.qcow2"
  overwrite = true
}
