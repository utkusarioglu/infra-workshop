dependencies {
  paths = [
    "../k3d-storage"
  ]
}

# include "provider_kubernetes" {
#   path = find_in_parent_folders("provider.kubernetes.hcl")
# }

include "provider_local_helm_k8s" {
  path = find_in_parent_folders("provider.local-helm-k8s.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}
