
terraform {
  required_providers {
    openwrt = {
      source = "joneshf/openwrt"
      version = "0.0.20"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}

variable "host" {
  type = string
}

resource "kubernetes_namespace" "immich" {
  metadata {
    name = "immich"
  }
}

resource "kubernetes_persistent_volume_v1" "immich_data" {
  metadata {
    name = "nfs-pv"
  }
  spec {
    capacity = {
      storage = "250Gi"
    }
    access_modes = ["ReadWriteMany"]
    storage_class_name = "nfs"
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      nfs {
        server = "truenas.lan"
        path = "/mnt/pool/k8s/immich"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "immich_data" {
  metadata {
    name = "immich-library-pvc"
    namespace = kubernetes_namespace.immich.metadata[0].name
  }
  spec {
    storage_class_name = "nfs"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "250Gi"
      }
    }
  }
  wait_until_bound = false
}

data "http" "cnpg_manifest" {
  url = "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.29/releases/cnpg-1.29.0.yaml"
}

data "kubectl_file_documents" "cnpg_docs" {
  content = data.http.cnpg_manifest.response_body
}

resource "kubectl_manifest" "cnpg" {
  for_each = data.kubectl_file_documents.cnpg_docs.manifests

  yaml_body         = each.value
  server_side_apply = true
  force_conflicts   = true
}


resource "kubectl_manifest" "cnpg_cluster" {
  yaml_body = file("${path.module}/postgres.yaml")
  depends_on = [kubectl_manifest.cnpg]
}

resource "helm_release" "immich" {
  namespace = kubernetes_namespace.immich.metadata[0].name
  name = "immich"
  repository = "https://immich-app.github.io/immich-charts"
  chart      = "immich"

  values = [
    file("${path.module}/values.yaml")
  ]
  depends_on = [kubectl_manifest.cnpg_cluster, kubernetes_persistent_volume_v1.immich_data]
}

resource "kubectl_manifest" "ingress" {
  yaml_body = yamlencode({
    apiVersion = "networking.k8s.io/v1"
    kind = "Ingress"
    metadata = {
      # For cert manager
      # annotations:                                # Add an annotation indicating the certificate issuer to use.
      #   cert-manager.io/cluster-issuer: ca-issuer # Cluster-wide ClusterIssuer
      name = "immichingress",
      namespace = kubernetes_namespace.immich.metadata[0].name
    }
    spec = {
      ingressClassName = "traefik"
      # tls:                                       # Placing a host in the TLS config will determine what ends up in the cert's subjectAltNames
      # - hosts:
      #   - immich.192-168-0-37.nip.io
      #   secretName: immich-cert                    # cert-manager will store the new certificate in this secret.
      rules = [
        {
          host = openwrt_dhcp_domain.immich.name,
          http = {
            paths = [
              {
                path = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name: "immich-server"
                    port = {
                      number = 2283
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  })
  depends_on=[helm_release.immich]
}

resource "openwrt_dhcp_domain" "immich" {
  id   = "immich"
  ip   = var.host
  name = "immich.homelab.lan"
}
