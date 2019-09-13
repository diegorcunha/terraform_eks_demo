variable "namespace" {
  description = "kubernetes namespace to deploy into"
  default     = "kube-system"
}

variable "service_account" {
  description = "kubernetes service account name"
  default     = "tiller"
}

variable "tiller_image" {
  description = "tiller docker image."
  default     = "gcr.io/kubernetes-helm/tiller:v2.14.1"
}

variable "aws_eks_cluster_demo" {
}

variable "aws_auth" {
}

variable "cluster-name" {
  type    = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}


variable "aws_iam_role_node" {

}

variable "aws_iam_role_master" {

}

variable "configuration" {
  description = "The configuration that should be applied"
}