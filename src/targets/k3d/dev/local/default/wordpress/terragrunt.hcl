dependencies {
  paths = [
    "../k3d-storage"
  ]
}

# include "provider_kubernetes" {
#   path = find_in_parent_folders("provider.kubernetes.hcl")
# }

include "provider_local_k8s_helm" {
  path = find_in_parent_folders("provider.local-k8s-helm.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}

inputs = {
  security_group_id = "you don't need this"
}
