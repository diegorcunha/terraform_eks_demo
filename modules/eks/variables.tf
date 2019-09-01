variable "vpc_id" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "keypair-name" {
  type = "string"
}

variable "cluster-name" {
  type    = "string"
}

variable "app_subnet_ids" {

}

variable "aws_auth" {
  default     = ""
  description = "Grant additional AWS users or roles the ability to interact with the EKS cluster."
}