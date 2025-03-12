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

# dependency "aws_k8s" {
#   config_path                             = "../aws-k8s"
#   mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
#   mock_outputs = {
#     alb_security_group_id = "mock"
#   }
# }

dependency "aws_eks_ec2" {
  config_path                             = "../aws-eks-ec2"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    alb_security_group_id = "mock"
  }
}

inputs = {
  security_group_id = dependency.aws_eks_ec2.outputs.alb_security_group_id
}
