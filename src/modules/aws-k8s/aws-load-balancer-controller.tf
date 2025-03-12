resource "aws_acm_certificate" "eks_domain_cert" {
  domain_name       = local.dns_base_domain
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${local.dns_base_domain}",
  ]
}

resource "aws_route53_record" "eks_domain_cert_validation_dns" {
  for_each = {
    for dvo in aws_acm_certificate.eks_domain_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.base_domain.zone_id
}

resource "aws_acm_certificate_validation" "eks_domain_cert_validation" {
  certificate_arn         = aws_acm_certificate.eks_domain_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.eks_domain_cert_validation_dns : record.fqdn]
}

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
  name            = "aws-load-balancer-controller"
  version         = "1.11.0"
  namespace       = "kube-system"
  repository      = "https://aws.github.io/eks-charts"
  chart           = "aws-load-balancer-controller"
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
