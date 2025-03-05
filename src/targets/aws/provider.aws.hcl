locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

generate "provider_aws" {
  path      = "provider.aws.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.inputs.names.region}"
      profile = "${local.inputs.profile}"
    }
  EOF
}
