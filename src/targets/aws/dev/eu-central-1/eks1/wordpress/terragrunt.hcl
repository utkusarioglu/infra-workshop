include "remote_state" {
  path = find_in_parent_folders("remote-state.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}

include "provider_aws" {
  path = find_in_parent_folders("provider.aws.hcl")
}

include "provider_aws_k8s_helm" {
  path = find_in_parent_folders("provider.aws-k8s-helm.hcl")
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
  tags                    = local.inputs.tags
}

terraform {
  after_hook "kubectl_api_resources_log" {
    commands    = ["apply"]
    working_dir = get_repo_root()
    execute = [
      "scripts/kubectl/log-api-resources.sh",
      local.inputs.id.dash.region,
      15
    ]
  }
}
