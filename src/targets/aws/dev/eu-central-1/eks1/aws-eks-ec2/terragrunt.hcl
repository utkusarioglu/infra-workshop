include "remote_state" {
  path = find_in_parent_folders("remote-state.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}

include "provider_aws" {
  path = find_in_parent_folders("terragrunt/providers/aws.hcl")
}

include "provider_http" {
  path = find_in_parent_folders("terragrunt/providers/http.hcl")
}

locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

inputs = {
  cluster_name = local.inputs.names.cluster
  platform     = local.inputs.names.platform
  region       = local.inputs.names.region
  tags         = local.inputs.tags
}

terraform {
  after_hook "eks_kubeconfig_register" {
    commands    = ["apply"]
    working_dir = get_repo_root()
    execute = [
      "scripts/eks/kubeconfig/update.sh",
      local.inputs.names.cluster,
      local.inputs.names.region,
      local.inputs.profile
    ]
    run_on_error = false
  }

  after_hook "eks_kubeconfig_remove" {
    commands    = ["destroy"]
    working_dir = get_repo_root()
    execute = [
      "scripts/eks/kubeconfig/remove.sh",
      local.inputs.names.cluster,
      local.inputs.names.region,
    ]
    run_on_error = false
  }

  after_hook "eks_ebs_delete" {
    commands    = ["destroy"]
    working_dir = get_repo_root()
    execute = [
      "scripts/ebs/delete-eks-ebs.sh",
      local.inputs.names.region,
      local.inputs.names.cluster,
      local.inputs.profile,
    ]
    run_on_error = true
  }
}
