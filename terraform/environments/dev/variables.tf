variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-2"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "lab-eks-auto"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.36"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["us-east-2a", "us-east-2b"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs (one per AZ)"
  default     = ["10.0.0.0/19", "10.0.32.0/19"]
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "eks-auto-dev"
}

variable "ecr_repository_name" {
  type        = string
  description = "ECR repository name"
  default     = "myapp"
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
  default = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Project     = "lab-eks-auto"
  }
}
