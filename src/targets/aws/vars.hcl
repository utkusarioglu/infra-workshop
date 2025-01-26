locals {
  parent = read_terragrunt_config(find_in_parent_folders("vars.hcl")).locals.vars

  vars = merge(
    local.parent,
    {
      profile = "nextjs-grpc-automation"
      tags = {
        Cluster      = local.parent.names.cluster
        ClusterShort = local.parent.names.cluster_short
        Platform     = local.parent.names.platform
        Region       = local.parent.names.region
        RegionShort  = local.parent.names.region_short
        Environment  = local.parent.names.environment
        Unit         = local.parent.names.unit
      }
    }
  )
}
