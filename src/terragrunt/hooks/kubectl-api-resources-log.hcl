/*
 * Runs `describe` on all kubernetes api resources and saves the outputs 
 * under the `artifacts` folder. 
 */

locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
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
