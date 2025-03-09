

# module "records" {
#   source  = "terraform-aws-modules/route53/aws//modules/records"
#   version = "~> 3.0"

#   zone_name = "utkusarioglu.com."

#   records = [
#     {
#       name = "eks1"
#       type = "CNAME"
#       ttl  = 3600
#       # records = ["k8s-default-wordpres-5f6c3281fb-664498526.eu-central-1.elb.amazonaws.com"]
#       records = ["k8s-default-wordpres-5f6c3281fb-1553719264.eu-central-1.elb.amazonaws.com"]
#     },
#   ]
# }



# resource "aws_route53_record" "wordpress" {
#   zone_id = aws_route53_zone.example.zone_id
#   name    = "wordpress.example.com"
#   type    = "A"

#   alias {
#     name                   = aws_lb.wordpress.dns_name
#     zone_id                = aws_lb.wordpress.zone_id
#     evaluate_target_health = true
#   }
# }



resource "helm_release" "wordpress" {
  name            = "wordpress"
  namespace       = "default"
  repository      = "oci://registry-1.docker.io/bitnamicharts"
  chart           = "wordpress"
  atomic          = true
  wait            = true
  cleanup_on_fail = true
  timeout         = 2 * 60
  # dependency_update = true

  values = [
    yamlencode({
      persistence = {
        enabled      = true
        storageClass = "gp2"
      }
      livenessProbe = {
        enabled = false
      }
      readinessProbe = {
        enabled = false
      }
      mariadb = {
        primary = {
          persistence = {
            storageClass = "gp2"
          }
        }
      }
      service = {
        type = "NodePort"
      }
      ingress = {
        enabled = true

        /*
         * these are aws specific
         */
        ingressClassName = "alb"
        hostname         = local.hostname
        path             = "/*"
        # pathType         = "Prefix"
        annotations = {
          "kubernetes.io/ingress.class"                        = "alb"
          "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"              = "ip" // or instance if clusterIp
          "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=60"
          "alb.ingress.kubernetes.io/listen-ports"             = jsonencode([{ HTTP = 80 }, { HTTPS = 443 }])
          "alb.ingress.kubernetes.io/ssl-redirect"             = "443"
          "alb.ingress.kubernetes.io/security-groups"          = join(",", [var.security_group_id])
          "alb.ingress.kubernetes.io/certificate-arn"          = module.cert.acm_certificate_arn
          "external-dns.alpha.kubernetes.io/hostname"          = local.hostname

          # "alb.ingress.kubernetes.io/group.name" : "nextjs-grpc"
          # "alb.ingress.kubernetes.io/load-balancer-name" : "nextjs-grpc"
        }
      }
    })
  ]
}
