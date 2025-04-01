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

include "kubectl_api_resources_log" {
  path = find_in_parent_folders("terragrunt/hooks/kubectl-api-resources-log.hcl")
}

dependencies {
  paths = [
    "../aws-eks-ec2",
    "../aws-k8s"
  ]
}

dependency "aws_eks_ec2" {
  config_path                             = "../aws-eks-ec2"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    alb_security_group_id = local.inputs.constants.MOCKED
  }
}

dependency "aws_k8s" {
  config_path                             = "../aws-k8s"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    aws_acm_certificate_arn = local.inputs.constants.MOCKED
  }
}

locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

inputs = {
  security_group_id       = dependency.aws_eks_ec2.outputs.alb_security_group_id
  aws_acm_certificate_arn = dependency.aws_k8s.outputs.aws_acm_certificate_arn
  platform                = local.inputs.names.platform
  dns                     = local.inputs.dns
  annotations             = local.inputs.annotations
}
