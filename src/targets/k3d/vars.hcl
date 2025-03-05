locals {
  _k3d_node_volume_root = get_env("K3D_NODE_VOLUME_ROOT")

  _inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs

  inputs = merge(
    local._inputs,
    {
      k3d_node_volume_root = local._k3d_node_volume_root
    }
  )
}

inputs = local.inputs
