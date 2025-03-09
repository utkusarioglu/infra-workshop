dependencies {
  paths = [
    "../k3d-cluster"
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

locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

inputs = {
  default_volume_path = local.inputs.k3d_node_volume_root
}
