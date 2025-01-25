locals {
  vars = read_terragrunt_config(find_in_parent_folders("vars.hcl")).locals

  identifier = join("-", [
    local.vars.cluster_code,
    local.vars.platform_name,
    local.vars.environment_name,
    local.vars.region_name,
    local.vars.module_name,
  ])
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
    region         = local.vars.region_name
    encrypt        = true
    dynamodb_table = local.identifier

    // THIS NEEDS TO CHANGE
    profile = "nextjs-grpc-automation"
  }
}
