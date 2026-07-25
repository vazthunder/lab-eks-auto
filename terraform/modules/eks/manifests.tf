data "aws_region" "current" {}

resource "null_resource" "nodepool" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      KUBECONFIG=$(mktemp); export KUBECONFIG
      aws eks update-kubeconfig --region ${data.aws_region.current.region} --name ${var.cluster_name} >/dev/null
      cat <<'YEOF' | kubectl apply -f -
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: spot
spec:
  template:
    spec:
      nodeClassRef:
        group: eks.amazonaws.com
        kind: NodeClass
        name: default
      requirements:
        - key: node.kubernetes.io/instance-type
          operator: In
          values: ["m7i-flex.large", "c7i-flex.large"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
YEOF
      rm "$KUBECONFIG"
    EOT
  }

  depends_on = [aws_eks_cluster.main]
}

resource "null_resource" "ingress_class" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      KUBECONFIG=$(mktemp); export KUBECONFIG
      aws eks update-kubeconfig --region ${data.aws_region.current.region} --name ${var.cluster_name} >/dev/null
      cat <<'YEOF' | kubectl apply -f -
---
apiVersion: eks.amazonaws.com/v1
kind: IngressClassParams
metadata:
  name: alb
spec:
  scheme: internet-facing
  group:
    name: main
---
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: alb
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
spec:
  controller: eks.amazonaws.com/alb
  parameters:
    apiGroup: eks.amazonaws.com
    kind: IngressClassParams
    name: alb
YEOF
      rm "$KUBECONFIG"
    EOT
  }

  depends_on = [aws_eks_cluster.main]
}

resource "null_resource" "storage_class" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      KUBECONFIG=$(mktemp); export KUBECONFIG
      aws eks update-kubeconfig --region ${data.aws_region.current.region} --name ${var.cluster_name} >/dev/null
      cat <<'YEOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
parameters:
  type: gp3
  encrypted: "true"
YEOF
      rm "$KUBECONFIG"
    EOT
  }

  depends_on = [aws_eks_cluster.main]
}

resource "time_sleep" "delay" {
  create_duration = "10s"

  depends_on = [
    null_resource.nodepool,
    null_resource.ingress_class,
    null_resource.storage_class,
  ]
}
