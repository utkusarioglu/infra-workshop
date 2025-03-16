include "provider_aws" {
  path = find_in_parent_folders("provider.aws.hcl")
}

include "provider_http" {
  path = find_in_parent_folders("provider.http.hcl")
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
  bucket_name    = local.inputs.id.dash.unit
  assets_abspath = local.inputs.abspath.assets.base
  tags           = local.inputs.tags
  dns = {
    domain_name = "utkusarioglu.com"
    subdomain   = local.inputs.names.label
  }
}
