resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  version    = "1.15.2"
  namespace  = "kube-system"

  values = [
    jsonencode({
      domainFilters = [
        local.dns_base_domain
      ]
      txtOwnerId         = data.aws_route53_zone.base_domain.zone_id
      logLevel           = "info"
      logFormat          = "json"
      triggerLoopOnEvent = "true"
      internal           = "5m"
      policy             = "sync"
      sources = [
        "ingress"
      ]
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.external_dns_iam_role}"
        }
      }
    })
  ]
}
