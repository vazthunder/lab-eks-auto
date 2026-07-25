output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_version" {
  value = module.eks.cluster_version
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "ecr_repository_url" {
  description = "ECR repository URL for the test app"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr.repository_arn
}

output "docker_build_command" {
  value = "docker build -t ${module.ecr.repository_url}:latest ../../app"
}

output "docker_push_command" {
  value = "docker push ${module.ecr.repository_url}:latest"
}

output "acm_certificate_arn" {
  value = module.acm.certificate_arn
}

output "acm_validation_records" {
  description = "CNAME records to add to DNS provider if not using Route53"
  value       = module.acm.validation_options
}

output "eksadmin_role_arn" {
  value = module.eks.eksadmin_role_arn
}

output "eksadmin_group_name" {
  value = module.eks.eksadmin_group_name
}
