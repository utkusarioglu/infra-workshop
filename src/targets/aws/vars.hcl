locals {
  _inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs

  inputs = merge(
    local._inputs,
    {
      profile = "nextjs-grpc-automation"
      tags = {
        Cluster      = local._inputs.names.cluster
        ClusterShort = local._inputs.names.cluster_short
        Platform     = local._inputs.names.platform
        Region       = local._inputs.names.region
        RegionShort  = local._inputs.names.region_short
        Environment  = local._inputs.names.environment
        Label        = local._inputs.names.label
        Unit         = local._inputs.names.unit
      }
    }
  )
}

inputs = local.inputs
