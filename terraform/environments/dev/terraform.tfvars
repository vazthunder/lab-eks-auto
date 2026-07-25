region               = "us-east-2"
cluster_name         = "lab-eks-auto"
k8s_version          = "1.36"
vpc_cidr             = "10.0.0.0/16"
azs                  = ["us-east-2a", "us-east-2b"]
private_subnet_cidrs = ["10.0.100.0/24", "10.0.200.0/24"]
ecr_repository_name  = "myapp"
name_prefix          = "eks-auto-dev"
public_access_cidrs  = ["157.90.228.173/32"] # Hetzner
domain_names         = ["eksauto.nemonobody.xyz", "*.eksauto.nemonobody.xyz"]
route53_zone_name    = "eksauto.nemonobody.xyz"
public_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24"]
argocd_version       = "10.2.1"
tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Project     = "lab-eks-auto"
}
