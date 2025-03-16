module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket = var.bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  website = {
    index_document = local.index_html
    error_document = local.error_html
  }

  attach_policy = true
  policy = jsonencode({
    version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        "Service" = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "arn:aws:s3:::${var.bucket_name}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = module.cloudfront.cloudfront_distribution_arn
        }
      }
    }]
  })
  tags = var.tags
}

module "s3_objects" {
  source   = "terraform-aws-modules/s3-bucket/aws//modules/object"
  for_each = fileset(local.label_assets_abspath, "*")

  bucket         = module.s3_bucket.s3_bucket_id
  content_base64 = filebase64(join("/", [local.label_assets_abspath, each.key]))
  key            = each.key
  content_type = lookup(
    jsondecode(data.http.mime_types.response_body),
    format(".%s", split(".", each.key)[length(split(".", each.key)) - 1]),
    "binary/octet-stream"
  )
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name            = local.fqdn
  wait_for_validation    = true
  validation_method      = "DNS"
  create_route53_records = true
  zone_id                = data.aws_route53_zone.this.zone_id
}

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "4.1.0"

  aliases             = [local.fqdn]
  comment             = var.bucket_name
  default_root_object = local.index_html
  retain_on_delete    = false
  wait_for_deployment = true

  create_origin_access_control = true
  origin_access_control = {
    s3_oac = {
      origin_type      = "s3"
      description      = "OAC for private S3 bucket"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    s3 = {
      domain_name           = module.s3_bucket.s3_bucket_bucket_domain_name
      origin_access_control = "s3_oac"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  viewer_certificate = {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

module "route53" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_id = data.aws_route53_zone.this.zone_id

  records = [
    {
      name = var.dns.subdomain
      type = "A"
      alias = {
        name                   = module.cloudfront.cloudfront_distribution_domain_name
        zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
        evaluate_target_health = false
      }
    }
  ]
}
