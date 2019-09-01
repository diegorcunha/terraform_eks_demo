
resource "kubernetes_storage_class" "persist_volume" {
  metadata {
    name = "generic"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  parameters = {
    type = "gp2"
    zones = "us-east-1a, us-east-1b"
    iopsPerGB: "100"
    fsType: "ext4"

  }
}

resource "kubernetes_persistent_volume_claim" "persist_volume_claim" {
  metadata {
    name = "jenkins-home-pvc"
    namespace = "jenkins"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "generic"
  }
  depends_on = [kubernetes_storage_class.persist_volume]
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    annotations = {
      name = "jenkins"
    }

    labels = {
      mylabel = "jenkins"
    }

    name = "jenkins"
  }
}

resource "helm_release" "jenkins" {
  name      = "jenkins"
  chart     = "stable/jenkins"
  values = ["${file("./modules/jenkins-setup/values.yaml")}"]
  namespace = "jenkins"
  depends_on = [kubernetes_namespace.jenkins, kubernetes_persistent_volume_claim.persist_volume_claim]
}