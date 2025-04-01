resource "kubernetes_service_account" "load_balancer_controller" {
  metadata {
    name      = local.ingress_gateway_name
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = local.ingress_gateway_name
    }

    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/load-balancer-controller"
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  version    = "1.11.0"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  atomic          = true
  wait            = true
  cleanup_on_fail = true
  wait_for_jobs   = true

  values = [
    yamlencode({
      clusterName = var.cluster_name
      serviceAccount = {
        name   = kubernetes_service_account.load_balancer_controller.metadata[0].name
        create = false
      }
      region = var.region
      vpcId  = var.vpc_id
    })
  ]
}
