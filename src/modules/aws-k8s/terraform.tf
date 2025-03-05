# Kubernetes Ingress Resource for ALB via AWS Auto Mode 
# variable "prefix_env" {
#   type = string
# }

variable "app_name" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

locals {
  cluster_name = var.cluster_name
  region       = var.region
  vpc_id       = var.vpc_id
}

# Create the K8s Service Account that will be used by Helm
resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }
}
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  set {
    name  = "clusterName"
    value = local.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  }
  set {
    name  = "region"
    value = local.region
  }
  set {
    name  = "vpcId"
    value = local.vpc_id
  }
}

locals {
  ingress_class_name = "alb"
}

# Kubernetes Ingress Resource for ALB via AWS Load Balancer Controller
resource "kubernetes_ingress_v1" "xyz_ingress_alb" {
  metadata {
    name      = "xyz-ingress-alb-${local.cluster_name}"
    namespace = "default"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"              = "ip"
      "alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=60"
    }
  }
  spec {
    ingress_class_name = local.ingress_class_name
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.xyz_service_alb.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}




# Kubernetes Service for the App
resource "kubernetes_service_v1" "xyz_service_alb" {
  metadata {
    name      = "xyz-service-alb-${local.cluster_name}"
    namespace = "default"
    labels = {
      app = var.app_name
    }
  }
  spec {
    selector = {
      app = var.app_name
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
  }
}
