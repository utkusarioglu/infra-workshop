include "provider_aws" {
  path = find_in_parent_folders("provider.aws.hcl")
}

include "remote_state" {
  path = find_in_parent_folders("remote-state.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("vars.hcl")).locals.vars
}

inputs = {
  cluster_code = local.vars.names.cluster_short
  tags         = local.vars.tags
}
