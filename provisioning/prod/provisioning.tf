
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    ansible = {
      version = "~> 1.4.0"
      source  = "ansible/ansible"
    }
    openwrt = {
      source = "joneshf/openwrt"
      version = "0.0.20"
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

variable "openwrt_password" {
  type = string
}

provider "proxmox" {
  endpoint = var.host
  username = var.username
  password = var.password
  insecure = true
}

provider "openwrt" {
  password = var.openwrt_password
}

data "terraform_remote_state" "proxmox" {
  backend = "local"
   
  config = {
    path = "${path.module}/../../proxmox/terraform.tfstate"
  }
}

locals {
  cloud_config_id = data.terraform_remote_state.proxmox.outputs.cloud_config_id
  debian_cloud_image_id = data.terraform_remote_state.proxmox.outputs.debian_cloud_image_id
}

