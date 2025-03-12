module "cert" {
  source = "terraform-aws-modules/acm/aws"

  domain_name         = local.hostname
  zone_id             = data.aws_route53_zone.this.zone_id
  validation_method   = "DNS"
  wait_for_validation = true
}
