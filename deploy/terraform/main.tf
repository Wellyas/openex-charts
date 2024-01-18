provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "openex" {
  count = 1
  name       = "openex"
  chart      = "../../charts/openex"
  depends_on = [ helm_release.minio ]

  set {
    name = "minio.enabled"
    value = "false"
  }
  set {
    name = "externalMinio.host"
    value = "minio"
  }
  set {
    name = "externalMinio.user"
    value = "admin"
  }
  set {
    name = "externalMinio.existingSecret"
    value = "minio"
  }

  set {
    name = "ingress.enabled"
    value = "true"
  }
  set {
    name = "ingress.hostname"
    value = ""
  }
  set {
    name = "ingress.tls"
    value = "true"
  }
  set {
    name = "ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt"
  }
}

resource "helm_release" "minio" {
  name = "minio"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "minio"
  
}

