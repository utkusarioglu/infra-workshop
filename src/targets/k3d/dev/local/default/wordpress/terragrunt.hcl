include "provider_local_k8s_helm" {
  path = find_in_parent_folders("provider.local-k8s-helm.hcl")
}

include "target" {
  path = find_in_parent_folders("target.hcl")
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
