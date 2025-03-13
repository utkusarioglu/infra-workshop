locals {
  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs
}

download_dir = local.inputs.abspath.terragrunt.download_dir

terraform {
  source = join("/", [local.inputs.abspath.modules, basename(get_terragrunt_dir())])

  # # // Needed by Vault 
  # # after_hook "kube_get_cluster_ca" {
  # #   commands    = ["plan", "apply"]
  # #   working_dir = get_repo_root()
  # #   execute = [
  # #     "scripts/kube/get-cluster-ca.sh",
  # #     join("/", [local.inputs.kube_artifacts_abspath, "cluster-ca.crt"])
  # #   ]
  # # }

  after_hook "tflint_validate" {
    commands    = ["validate"]
    working_dir = get_repo_root()
    execute     = ["sh", "-c", "tflint --config=./.tflint.hcl -f default"]
  }


  before_hook "inputs_output" {
    commands    = ["validate"]
    working_dir = get_repo_root()
    execute = [
      "scripts/yq/echo.sh",
      yamlencode(local.inputs),
    ]
  }
}
