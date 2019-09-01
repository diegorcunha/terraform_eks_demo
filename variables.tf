variable "aws_region" {
  type = "string"
  default = "us-east-1"
}
variable "subnet_count" {
  type = "string"
  default = "2"
}

variable "keypair-name" {
  type = "string"
  default = "ClassAWS"
}

variable "cluster-name" {
  default = "eks-test-dev"
  type    = "string"
}
//variable "hosted_zone_id" {
//  type = "string"
//  default = "Z185D5G476X9HW"
//}
//
//variable "hosted_zone_url" {
//  type = "string"
//  default = "diegocloud.tk"
//}

