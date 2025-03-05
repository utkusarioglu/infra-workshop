dependency "aws_eks_ec2" {
  config_path = "../aws-eks-ec2"
}

include "provider_kubernetes" {
  path = find_in_parent_folders("provider.kubernetes.hcl")
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
  # region       = local.inputs.id.dash.region
  # app_name     = local.inputs.names.cluster_short
  # cluster_name = local.inputs.names.cluster
  # vpc_id       = dependency.aws_eks_ec2.outputs.vpc_id
  # aws_region   = local.inputs.names.region
}
