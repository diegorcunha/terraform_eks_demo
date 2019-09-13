resource "helm_release" "metrics-server" {
  name      = "metrics-server"
  chart     = "stable/metrics-server"
  namespace = "kube-system"
  depends_on = [kubernetes_deployment.tiller_deploy]
}