include "provider_local_k8s_helm" {
  path = find_in_parent_folders("provider.local-k8s-helm.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}

dependencies {
  paths = [
    "../k3d-cluster"
  ]
}

locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

inputs = {
  default_volume_path = local.inputs.k3d_node_volume_root
}
