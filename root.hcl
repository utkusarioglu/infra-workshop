locals {
  cluster_name = "infra-workshop"

  module_src_path   = split("${get_env("TARGETS_RELPATH")}/", get_original_terragrunt_dir())[1]
  module_path_array = split("/", local.module_src_path)

  platform    = local.module_path_array[0]
  environment = local.module_path_array[1]
  region      = local.module_path_array[2]
  module      = local.module_path_array[3]

  environment_path = join("/", [local.platform, local.environment])
  region_path      = join("/", [local.platform, local.environment, local.region])
  module_path      = join("/", local.module_path_array)

  config_abspath = join("/", [get_repo_root(), get_env("CONFIG_RELPATH")])
  # artifacts_abspath = join("/", [get_repo_root(), get_env("ARTIFACTS_RELPATH")])

  devcontainer_pass = "catdog"
}

download_dir = join("/", [get_repo_root(), "artifacts/cache"])

terraform {
  source = join("/", [
    get_repo_root(),
    get_env("MODULES_RELPATH"),
    basename(get_terragrunt_dir())
  ])
}
