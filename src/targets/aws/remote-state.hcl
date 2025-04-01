locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

remote_state {
  backend = "s3"

  generate = {
    path      = "remote-state.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = format("%s-tfstate", local.inputs.id.dash.region)
    key            = format("%s.tfstate", local.inputs.id.dash.unit)
    region         = local.inputs.names.region
    encrypt        = true
    dynamodb_table = format("%s-tfstate", local.inputs.id.dash.unit)
    profile        = local.inputs.profile
  }
}
