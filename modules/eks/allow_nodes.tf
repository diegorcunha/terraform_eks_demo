locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.demo.endpoint}
    certificate-authority-data: ${aws_eks_cluster.demo.certificate_authority.0.data}
  name: ${aws_eks_cluster.demo.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.demo.name}
    user: ${aws_eks_cluster.demo.name}
  name: ${aws_eks_cluster.demo.name}
current-context: ${aws_eks_cluster.demo.name}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.demo.name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.demo.name}"
KUBECONFIG

  aws_auth = <<AWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.demo-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
${var.aws_auth}
AWSAUTH

}

resource "null_resource" "output" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/output/${var.cluster-name}"
  }
}

resource "local_file" "kubeconfig" {
  content  = "${local.kubeconfig}"
  filename = "${path.root}/output/${var.cluster-name}/kubeconfig-${var.cluster-name}"

  depends_on = [
    "null_resource.output",
  ]
}

resource "local_file" "aws_auth" {
  content  = "${local.aws_auth}"
  filename = "${path.root}/output/${var.cluster-name}/aws-auth.yaml"

  depends_on = [
    "null_resource.output",
  ]
}

resource "null_resource" "kubectl" {

  provisioner "local-exec" {
    command = <<COMMAND
      KUBECONFIG=~/.kube/config:${path.root}/output/${var.cluster-name}/kubeconfig-${var.cluster-name} kubectl config view --flatten > ./kubeconfig_merged \
      && mv ./kubeconfig_merged ~/.kube/config \
      && kubectl config use-context ${var.cluster-name}
    COMMAND
  }

  depends_on = [
    "aws_eks_cluster.demo",
    "null_resource.output",
  ]
}

resource "null_resource" "kubeconfig" {

  provisioner "local-exec" {
    command = <<COMMAND
      export KUBECONFIG=${path.root}/output/${var.cluster-name}/kubeconfig-${var.cluster-name}
    COMMAND
  }

  depends_on = [
    "null_resource.kubectl",
  ]
}

resource "null_resource" "aws_auth" {
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${path.root}/output/${var.cluster-name}/kubeconfig-${var.cluster-name} -f ${path.root}/output/${var.cluster-name}/aws-auth.yaml"
  }

  depends_on = [
    "null_resource.kubeconfig",
  ]
}