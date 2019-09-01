
resource "aws_iam_policy" "alb-ingress-controler-s3-policy" {
  name = "alb-ingress-controler-s3"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  role       = "${var.aws_iam_role}"
  policy_arn = "${aws_iam_policy.alb-ingress-controler-s3-policy.arn}"
}

resource "kubernetes_service_account" "alb-ingress-controller-sa" {
  metadata {
    name = "alb-ingress-controller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role" "cluster_role" {
  metadata {
    name = "alb-ingress-controller"
    labels = {
      "app" = "alb-ingress-controller"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }
  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_role_bind" {
  metadata {
    name = "alb-ingress-controller"

    labels = {
      app = "alb-ingress-controller"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    name = kubernetes_cluster_role.cluster_role.metadata[0].name
    kind = "ClusterRole"
  }

  subject {
    api_group = ""
    kind = "ServiceAccount"
    name = kubernetes_service_account.alb-ingress-controller-sa.metadata[0].name
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "alb-ingress-controller"
    namespace = "kube-system"

    labels = {
      app = "alb-ingress-controller"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "alb-ingress-controller"
      }
    }

    template {
      metadata {
        labels = {
          app = "alb-ingress-controller"
        }
      }

      spec {
        automount_service_account_token = true
        service_account_name = kubernetes_service_account.alb-ingress-controller-sa.metadata[0].name

        container {
          name = "alb-ingress-controller"
          image = "docker.io/amazon/aws-alb-ingress-controller:v1.1.2"
          image_pull_policy = "Always"

          # Limit the namespace where this ALB Ingress Controller deployment will
          # resolve ingress resources. If left commented, all namespaces are used.
          # - --watch-namespace=your-k8s-namespace

          # Setting the ingress-class flag below ensures that only ingress resources with the
          # annotation kubernetes.io/ingress.class: "alb" are respected by the controller. You may
          # choose any class you'd like for this controller to respect.
          # - --ingress-class=alb

          # Name of your cluster. Used when naming resources created
          # by the ALB Ingress Controller, providing distinction between
          # clusters.
          # - --cluster-name=your-cluster-name

          # AWS VPC ID this ingress controller will use to create AWS resources.
          # If unspecified, it will be discovered from ec2metadata.
          # - --aws-vpc-id=vpc-xxxxxx

          # AWS region this ingress controller will operate in.
          # If unspecified, it will be discovered from ec2metadata.
          # List of regions: http://docs.aws.amazon.com/general/latest/gr/rande.html#vpc_region
          # - --aws-region=us-west-1

          # Enables logging on all outbound requests sent to the AWS API.
          # If logging is desired, set to true.
          # - ---aws-api-debug
          # Maximum number of times to retry the aws calls.
          # defaults to 10.
          # - --aws-max-retries=10
          args = [
            "--ingress-class=alb",
            "--cluster-name=${var.cluster-name}",
            "--aws-vpc-id=${var.vpc_id}",
            "--aws-region=${var.aws_region}",
          ]
          security_context {
            allow_privilege_escalation = "false"
            privileged = "false"
            run_as_user = "999"
            run_as_non_root = "true"
          }
        }
      }
    }
  }
}