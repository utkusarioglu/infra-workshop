data "aws_route53_zone" "this" {
  name = local.tld
}
