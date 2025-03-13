locals {
  ingress_chart_values = {
    common = {
    }
    k3d = {
      livenessProbe = {
        enabled = true
      }
      readinessProbe = {
        enabled = true
      }
      ingress = {
        enabled = true
      }
    }
    aws = {
      livenessProbe = {
        enabled = false
      }
      readinessProbe = {
        enabled = false
      }
      persistence = {
        enabled      = true
        storageClass = "gp2"
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

        ingressClassName = "alb"
        hostname         = var.dns.hostname
        path             = "/*"
        annotations = {
          "kubernetes.io/ingress.class"                        = "alb"
          "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"              = "ip" // or instance if clusterIp
          "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=60"
          "alb.ingress.kubernetes.io/listen-ports"             = jsonencode([{ HTTP = 80 }, { HTTPS = 443 }])
          "alb.ingress.kubernetes.io/ssl-redirect"             = "443"
          "alb.ingress.kubernetes.io/security-groups"          = join(",", [var.security_group_id])
          "alb.ingress.kubernetes.io/certificate-arn"          = var.aws_acm_certificate_arn
          "external-dns.alpha.kubernetes.io/hostname"          = var.dns.hostname
        }
      }
    }
  }
}
