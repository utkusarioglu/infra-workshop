module "cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name         = var.dns.hostname
  zone_id             = data.aws_route53_zone.base_domain.zone_id
  validation_method   = "DNS"
  wait_for_validation = true

  tags = var.tags
}
