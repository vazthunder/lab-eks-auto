resource "kubernetes_manifest" "nodeclass" {
  manifest = {
    apiVersion = "eks.amazonaws.com/v1"
    kind       = "NodeClass"
    metadata = {
      name = "private"
    }
    spec = {
      role = "${var.name_prefix}-node"
      subnetSelectorTerms = [
        {
          tags = {
            "kubernetes.io/role/internal-elb" = "1"
          }
        }
      ]
      securityGroupSelectorTerms = [
        {
          tags = {
            "kubernetes.io/cluster/${var.cluster_name}" = "owned"
          }
        }
      ]
    }
  }

  depends_on = [aws_eks_cluster.main]
}

resource "aws_eks_access_entry" "auto_node" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.node.arn
  type          = "EC2"
}

resource "aws_eks_access_policy_association" "auto_node" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.node.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"
  access_scope {
    type = "cluster"
  }
}
