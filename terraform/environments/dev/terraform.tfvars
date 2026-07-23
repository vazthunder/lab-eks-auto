region               = "us-east-2"
cluster_name         = "lab-eks-auto"
k8s_version          = "1.36"
vpc_cidr             = "10.0.0.0/16"
azs                  = ["us-east-2a", "us-east-2b"]
private_subnet_cidrs = ["10.0.0.0/19", "10.0.32.0/19"]
ecr_repository_name  = "myapp"
name_prefix          = "eks-auto-dev"
tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Project     = "lab-eks-auto"
}
