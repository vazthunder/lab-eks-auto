resource "helm_release" "argo-cd" {
  name             = "argo-cd"
  namespace        = "argo-cd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_version

  values = [
    yamlencode({
      global = {
        domain = "argo-cd.eksauto.nemonobody.xyz"
      }
      dex = {
        enabled = false
      }
      notifications = {
        enabled = false
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
      service = {
        type = "NodePort"
      }
      server = {
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          annotations = {
            "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\":443}]"
            "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
            "external-dns.alpha.kubernetes.io/hostname" = "argo-cd.eksauto.nemonobody.xyz"
          }
        }
      }
    })
  ]

  depends_on = [
    aws_eks_cluster.main,
    time_sleep.delay,
  ]
}
