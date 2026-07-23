module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  private_subnet_cidrs = var.private_subnet_cidrs
  name_prefix          = var.name_prefix
  tags                 = var.tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = var.ecr_repository_name
  tags            = var.tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = var.cluster_name
  k8s_version  = var.k8s_version
  subnet_ids   = module.vpc.private_subnet_ids
  name_prefix  = var.name_prefix
  tags         = var.tags
}
