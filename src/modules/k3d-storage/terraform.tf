variable "default_volume_path" {
  type = string
}

resource "helm_release" "local_path_provisioner" {
  name       = "host-volumes-provisioner"
  chart      = "local-path-provisioner"
  repository = "https://charts.containeroo.ch"
  version    = "0.0.31"
  namespace  = "kube-system"

  cleanup_on_fail = true
  lint            = true
  atomic          = true
  timeout         = 60

  values = [
    yamlencode({
      storageClass = {
        create       = true
        defaultClass = true
      }
      nodePathMap = [
        {
          node  = "DEFAULT_PATH_FOR_NON_LISTED_NODES"
          paths = [var.default_volume_path]
        }
      ]
      # configmap = {
      #   setup = file(join("/", [path.module, "local-path-provisioner-setup.sh"]))
      # }
    })
  ]
  # set {
  #   name  = "storageClass.create"
  #   value = false
  # }

  # set {
  #   name  = "nodePathMap[0].node"
  #   value = "DEFAULT_PATH_FOR_NON_LISTED_NODES"
  # }

  # set {
  #   name  = "nodePathMap[0].paths"
  #   value = "{${var.default_volume_path}}"
  # }

  # set {
  #   name = "storageClass.provisionerName"
  #   # Storage classes require on the variable below.
  #   # But they inherit it from the `name` of this resource.
  #   # So, changing this without changing the `name` attribute 
  #   # will break storage classes.
  #   value = var.host_volumes_provisioner_resource_name
  # }
}

# resource "kubernetes_manifest" "wp_mariadb_sc" {
#   count = 1

#   manifest = yamldecode(templatefile("${path.module}/wp-mariadb-sc.yaml", {
#     default_volume_path = var.default_volume_path
#     # node_index          = count.index
#   }))
# }
