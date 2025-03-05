dependencies {
  paths = [
    "../k3d-storage"
  ]
}

include "provider_kubernetes" {
  path = find_in_parent_folders("provider.kubernetes.hcl")
}

include "provider_helm" {
  path = find_in_parent_folders("provider.helm.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}
