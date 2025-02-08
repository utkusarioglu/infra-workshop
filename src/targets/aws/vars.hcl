locals {
  parent = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs

  inputs = merge(
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

inputs = local.inputs

# terraform {
#   after_hook "ssh_private_key" {
#     commands = ["apply"]
#     execute  = ["echo", outputs.ssh_private_key, "> private-key.pem"]
#   }
# }
