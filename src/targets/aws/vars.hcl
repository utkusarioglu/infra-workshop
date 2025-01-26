locals {
  parent = read_terragrunt_config(find_in_parent_folders("vars.hcl")).locals.vars

  vars = merge(
    local.parent,
    {
      profile = "nextjs-grpc-automation"
    }
  )
}
