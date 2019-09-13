resource "aws_iam_policy" "cluster-autoscaler" {
  name = "cluster-autoscaler-eks-gwaereo-dev"
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
  depends_on = [kubernetes_deployment.tiller_deploy]
}


resource "aws_iam_role_policy_attachment" "role-policy-attachment_master" {
  role       = "${var.aws_iam_role_master}"
  policy_arn = "${aws_iam_policy.cluster-autoscaler.arn}"
  depends_on = [aws_iam_policy.cluster-autoscaler]
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment_node" {
  role       = "${var.aws_iam_role_node}"
  policy_arn = "${aws_iam_policy.cluster-autoscaler.arn}"
  depends_on = [aws_iam_policy.cluster-autoscaler]
}

resource "null_resource" "kubernetes_resource" {
  triggers = {
    content = "${var.configuration}"
  }

  provisioner "local-exec" {
    command = " kubectl apply  -f - <<EOF\n${var.configuration}\nEOF"
  }

  provisioner "local-exec" {
    command = "kubectl delete -f - <<EOF\n${var.configuration}\nEOF"
    when    = "destroy"
  }
}