
terraform {
  required_providers {
    ansible = {
      version = "~> 1.4.0"
      source  = "ansible/ansible"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
    dns = {
      source = "hashicorp/dns"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    openwrt = {
      source = "joneshf/openwrt"
      version = "0.0.20"
    }
  }
}

variable "openwrt_password" {
  type = string
}

variable "namespace" {
  type = string
}

variable "remote_state_path" {
  type = string
}

provider "dns" {}


data "terraform_remote_state" "provisioning" {
  backend = "local"
   
  config = {
    path = "${path.module}/${var.remote_state_path}"
  }
}

data "dns_a_record_set" "server" {
  host = data.terraform_remote_state.provisioning.outputs.k3s_server
}

resource "ansible_playbook" "server_kubeconfig" {
  playbook   = "${path.module}/playbooks/read_server_kubeconfig.yaml"
  name       = data.terraform_remote_state.provisioning.outputs.k3s_server
  replayable = false

  extra_vars = {
    ansible_user                 = "erik"
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
  }

}

locals {
  host = data.dns_a_record_set.server.addrs[0]
  ca_certificate = base64decode(regex(
    "TF_K8S_CLUSTER_CA_CERTIFICATE=(.+)\"",
    ansible_playbook.server_kubeconfig.ansible_playbook_stdout
  )[0])
  client_certificate = base64decode(regex(
    "TF_K8S_CLIENT_CERTIFICATE=(.+)\"",
    ansible_playbook.server_kubeconfig.ansible_playbook_stdout
  )[0])
  client_key= base64decode(regex(
    "TF_K8S_CLIENT_KEY=(.+)\"",
    ansible_playbook.server_kubeconfig.ansible_playbook_stdout
  )[0])
}

provider "kubernetes" {
  host = "https://${local.host}:6443"
  client_key = local.client_key
  cluster_ca_certificate = local.ca_certificate
  client_certificate = local.client_certificate
}

provider "helm" {
  kubernetes = {
    host = "https://${local.host}:6443"
    client_key = local.client_key
    client_certificate = local.client_certificate
    cluster_ca_certificate = local.ca_certificate
  }
}

provider "kubectl" {
  host = "https://${local.host}:6443"
  client_key = local.client_key
  cluster_ca_certificate = local.ca_certificate
  client_certificate = local.client_certificate
  load_config_file       = false
}

provider "openwrt" {
  password = var.openwrt_password
}

module "immich" {
  source = "./immich_service/"
  host = local.host
  namespace = var.namespace
  providers = {
    kubernetes = kubernetes
    kubectl = kubectl
    helm = helm
    openwrt = openwrt
  }
}

output "immich_url" {
  value = "http://${module.immich.url}"
}
