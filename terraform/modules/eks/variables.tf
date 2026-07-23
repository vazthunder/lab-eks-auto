variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the EKS cluster"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for IAM role names"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
