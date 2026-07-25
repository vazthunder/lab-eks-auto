resource "kubernetes_manifest" "nodepool_burstable" {
  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "burstable"
    }
    spec = {
      template = {
        spec = {
          nodeClassRef = {
            group = "eks.amazonaws.com"
            kind  = "NodeClass"
            name  = "private"
          }
          requirements = [
            {
              key      = "node.kubernetes.io/instance-type"
              operator = "In"
              values   = var.node_type
            }
          ]
        }
      }
    }
  }

  depends_on = [
    aws_eks_cluster.main,
    kubernetes_manifest.nodeclass,
  ]
}
