output "node_sg_id" {
  value = "${aws_security_group.demo-node.id}"
}

output "aws_eks_cluster_demo" {
  value = "${aws_eks_cluster.demo.name}"
}

output "aws_auth" {
  value = "${null_resource.aws_auth}"
}

output "aws_iam_role" {
  value = "${aws_iam_role.demo-node.name}"
}