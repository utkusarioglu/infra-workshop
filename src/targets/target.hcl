locals {
  vars = read_terragrunt_config(find_in_parent_folders("vars.hcl")).locals
}

download_dir = local.vars.terragrunt_download_dir_abspath

terraform {
  source = join("/", [local.vars.modules_abspath, basename(get_terragrunt_dir())])

  # // Needed by Vault 
  # after_hook "kube_get_cluster_ca" {
  #   commands    = ["plan", "apply"]
  #   working_dir = get_repo_root()
  #   execute = [
  #     "scripts/kube/get-cluster-ca.sh",
  #     join("/", [local.vars.kube_artifacts_abspath, "cluster-ca.crt"])
  #   ]
  # }

  after_hook "tflint_validate" {
    commands = ["validate"]
    execute  = ["sh", "-c", "tflint --config=.tflint.hcl -f default"]
  }
}
