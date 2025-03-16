resource "helm_release" "wordpress" {
  name       = "wordpress"
  namespace  = "default"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "wordpress"

  atomic          = true
  wait            = true
  cleanup_on_fail = true
  timeout         = 2 * 60
  # dependency_update = true

  values = [
    yamlencode(local.ingress_chart_values["common"]),
    yamlencode(local.ingress_chart_values[var.platform]),
  ]
}

# resource "helm_release" "wordpress" {
#   name       = "wordpress"
#   namespace  = "default"
#   repository = "oci://registry-1.docker.io/bitnamicharts"
#   chart      = "wordpress"

#   atomic          = true
#   wait            = true
#   cleanup_on_fail = true
#   timeout         = 2 * 60
#   # dependency_update = true

#   values = [
#     yamlencode({
#       commonLabels = {
#         for a in var.annotations : a.key => a.value
#       }
#       livenessProbe = {
#         enabled = false
#       }
#       readinessProbe = {
#         enabled = false
#       }
#       persistence = {
#         enabled      = true
#         storageClass = "gp2"
#       }
#       mariadb = {
#         primary = {
#           persistence = {
#             storageClass = "gp2"
#           }
#         }
#       }
#       service = {
#         type = "NodePort"
#       }
#       ingress = {
#         enabled = true

#         ingressClassName = "alb"
#         hostname         = var.dns.hostname
#         path             = "/*"
#         annotations = {
#           "kubernetes.io/ingress.class"                        = "alb"
#           "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
#           "alb.ingress.kubernetes.io/target-type"              = "ip" // or instance if clusterIp
#           "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=60"
#           "alb.ingress.kubernetes.io/listen-ports"             = jsonencode([{ HTTP = 80 }, { HTTPS = 443 }])
#           "alb.ingress.kubernetes.io/ssl-redirect"             = "443"
#           "alb.ingress.kubernetes.io/security-groups"          = join(",", [var.security_group_id])
#           "alb.ingress.kubernetes.io/certificate-arn"          = var.aws_acm_certificate_arn
#           "external-dns.alpha.kubernetes.io/hostname"          = var.dns.hostname
#         }
#       }
#     }),
#   ]
# }
