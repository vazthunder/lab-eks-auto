output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_arn" {
  value = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  value = aws_eks_cluster.main.version
}

output "oidc_issuer" {
  value = aws_eks_cluster.main.identity[*].oidc[*].issuer
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.main.certificate_authority[*].data
}
