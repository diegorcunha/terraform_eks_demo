
module "network" {
  source                  = "./modules/network"
  aws_region              = "${var.aws_region}"
  subnet_count            = "${var.subnet_count}"
  cluster-name            = "${var.cluster-name}"
  aws_availability_zones  = "${data.aws_availability_zones.available.names}"
}

module "eks" {
  source                  = "./modules/eks"
  aws_region              = "${var.aws_region}"
  keypair-name            = "${var.keypair-name}"
  vpc_id                  = "${module.network.vpc_id}"
  app_subnet_ids          = "${module.network.app_subnet_ids}"
  cluster-name            = "${var.cluster-name}"
}

module "dependencies" {
  source                  = "./modules/dependencies"
  aws_eks_cluster_demo    = "${module.eks.aws_eks_cluster_demo}"
  aws_auth                = "${module.eks.aws_auth}"
  aws_region              = "${var.aws_region}"
  vpc_id                  = "${module.network.vpc_id}"
  aws_iam_role_node       = "${module.eks.aws_iam_role_node}"
  aws_iam_role_master     = "${module.eks.aws_iam_role_master}"
  cluster-name            = "${var.cluster-name}"
  configuration           = "${file("./modules/dependencies/cluster_autoscaler.yaml")}"
}

module "jenkins-setup" {
  source                  = "./modules/jenkins-setup"
  aws_availability_zones  = "${data.aws_availability_zones.available.names}"
  subnet_count            = "${var.subnet_count}"
}
