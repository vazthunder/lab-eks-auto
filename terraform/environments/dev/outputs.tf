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

output "ssm_tunnel_command" {
  description = "Command to tunnel kubectl through SSM to reach private-only EKS endpoint"
  value       = <<-EOT
    aws ssm start-session \\
      --target <bastion-instance-id> \\
      --document-name AWS-StartPortForwardingSessionToRemoteHost \\
      --parameters '{"host":["${module.eks.cluster_endpoint}"],"portNumber":["443"],"localPortNumber":["8443"]}'
  EOT
}
