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
    yamlencode(local.ingress_chart_values["common"]),
    yamlencode(local.ingress_chart_values[var.platform]),
  ]
}
