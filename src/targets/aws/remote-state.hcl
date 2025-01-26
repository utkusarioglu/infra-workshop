locals {
  vars     = read_terragrunt_config(find_in_parent_folders("vars.hcl")).locals
  vars_aws = read_terragrunt_config(find_in_parent_folders("vars.aws.hcl")).locals

  identifier = join("-",
    concat(
      [local.vars.cluster_code],
      matchkeys(
        values(local.vars.names),
        keys(local.vars.names),
        ["platform", "environment", "region_short", "unit"]
      )
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
    region         = local.vars.names.region
    encrypt        = true
    dynamodb_table = local.identifier
    profile        = local.vars_aws.profile
  }
}
