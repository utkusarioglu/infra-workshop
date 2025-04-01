include "provider_local_k8s_helm" {
  path = find_in_parent_folders("terragrunt/providers/local-k8s-helm.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
}

include "kubectl_api_resources_log" {
  path = find_in_parent_folders("terragrunt/hooks/kubectl-api-resources-log.hcl")
}

dependencies {
  paths = [
    "../k3d-storage"
  ]
}

locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

inputs = {
  security_group_id       = local.inputs.constants.MOCKED
  aws_acm_certificate_arn = local.inputs.constants.MOCKED
  platform                = local.inputs.names.platform
  dns                     = local.inputs.dns
  annotations             = local.inputs.annotations
}
