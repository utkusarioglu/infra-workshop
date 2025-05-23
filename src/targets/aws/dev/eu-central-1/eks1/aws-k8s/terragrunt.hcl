include "remote_state" {
  path = find_in_parent_folders("remote-state.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}

include "provider_aws" {
  path = find_in_parent_folders("terragrunt/providers/aws.hcl")
}

include "provider_aws_k8s_helm" {
  path = find_in_parent_folders("terragrunt/providers/aws-k8s-helm.hcl")
}

dependency "aws_eks_ec2" {
  config_path = "../aws-eks-ec2"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    vpc_id = local.inputs.constants.MOCKED
  }
}

locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

inputs = {
  region       = local.inputs.names.region
  cluster_name = local.inputs.names.cluster
  vpc_id       = dependency.aws_eks_ec2.outputs.vpc_id
  dns          = local.inputs.dns
  tags         = local.inputs.tags
}
