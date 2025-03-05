resource "helm_release" "wordpress" {
  name            = "wordpress"
  namespace       = "default"
  repository      = "oci://registry-1.docker.io/bitnamicharts"
  chart           = "wordpress"
  atomic          = true
  wait            = true
  cleanup_on_fail = true
  timeout         = 5 * 60
  # dependency_update = true

  values = [
    yamlencode({
      persistence = {
        enabled = true
        # storageClass = "wp-mariadb-sc"
      }
      livenessProbe = {
        enabled = true
      }
      readinessProbe = {
        enabled = true
      }
      ingress = {
        enabled = true
      }
      # nodeSelector = [
      #   {
      #     matchExpressions = {
      #       key      = "kubernetes.io/hostname"
      #       operator = "In"
      #       values = [
      #         "worker-0"
      #       ]
      #     }
      #   }
      # ]


      # affinity = {
      #   nodeAffinity = {
      #     required = {
      #       nodeSelectorTerms = [
      #       ]
      #     }
      #   }
      # }
      # wordpressPassword = "cat"
    })
  ]
}
