locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs

  identifier = join("-", matchkeys(
    values(local.inputs.names),
    keys(local.inputs.names),
    ["cluster_short", "platform", "environment", "region_short", "unit"]
  ))
}

remote_state {
  backend = "s3"

  generate = {
    path      = "remote-state.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = local.identifier
    key            = "terraform.tfstate"
    region         = local.inputs.names.region
    encrypt        = true
    dynamodb_table = local.identifier
    profile        = local.inputs.profile
  }
}
