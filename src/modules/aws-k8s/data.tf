data "aws_caller_identity" "current" {}

data "aws_route53_zone" "base_domain" {
  name = var.dns.base_domain
}
