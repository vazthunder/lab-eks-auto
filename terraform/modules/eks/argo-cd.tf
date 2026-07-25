resource "helm_release" "argo-cd" {
  name             = "argo-cd"
  namespace        = "argo-cd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_version

  set = [
    {
      name  = "dex.enabled"
      value = "false"
    },
    {
      name  = "notifications.enabled"
      value = "false"
    }
  ]

  depends_on = [
    aws_eks_cluster.main,
    time_sleep.delay,
  ]
}
