include "provider_aws" {
  path = find_in_parent_folders("terragrunt/providers/aws.hcl")
}

include "remote_state" {
  path = find_in_parent_folders("remote-state.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}

locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

inputs = {
  cluster_code = local.inputs.names.cluster_short
  region       = local.inputs.names.region
  tags         = local.inputs.tags

  availability_zone = "${local.inputs.names.region}a"
  cidr_block        = "10.0.0.0/16"
}
