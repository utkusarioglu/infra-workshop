include "provider_aws" {
  path = find_in_parent_folders("provider.aws.hcl")
}

include "provider_helm" {
  path = find_in_parent_folders("provider.helm.hcl")
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
  cluster_name = local.inputs.names.cluster
  region       = local.inputs.names.region
  # cluster_code = local.inputs.names.cluster_short
  tags = local.inputs.tags

  # availability_zone      = "${local.inputs.names.region}a"
  # key_pair_name          = "some-key-pair"
  # instance_type          = "t3.micro"
  # cidr_block             = "10.0.0.0/16"
  # abspath_artifacts_base = local.inputs.abspath.artifacts.base
}



terraform {
  after_hook "eks_kubeconfig_register" {
    commands = ["apply"]
    execute = [
      join("/", [
        get_repo_root(),
        "scripts/eks/kubeconfig/update.sh",
      ]),
      local.inputs.names.cluster,
      local.inputs.names.region,
      local.inputs.profile
    ]
    run_on_error = false
  }

  after_hook "eks_kubeconfig_remove" {
    commands = ["destroy"]
    execute = [
      join("/", [
        get_repo_root(),
        "scripts/eks/kubeconfig/remove.sh",
      ]),
      local.inputs.names.cluster,
      local.inputs.names.region,
    ]
    run_on_error = false
  }
}
