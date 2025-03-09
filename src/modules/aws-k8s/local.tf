locals {
  cluster_name         = var.cluster_name
  region               = var.region
  vpc_id               = var.vpc_id
  ingress_gateway_name = "aws-load-balancer-controller"
  dns_base_domain      = "utkusarioglu.com"

  # TODO upgrade
  external_dns_iam_role      = "external-dns"
  external_dns_chart_name    = "external-dns"
  external_dns_chart_repo    = "https://kubernetes-sigs.github.io/external-dns/"
  external_dns_chart_version = "1.15.2"

  external_dns_values = {
    "image.repository" = "k8s.gcr.io/external-dns/external-dns",
    # "image.tag"          = "v0.11.0",
    "logLevel"           = "info",
    "logFormat"          = "json",
    "triggerLoopOnEvent" = "true",
    "interval"           = "5m",
    "policy"             = "sync",
    "sources"            = "{ingress}"
  }
}
