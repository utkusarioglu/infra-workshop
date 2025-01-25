locals {
  cluster_name      = "infra-workshop"
  devcontainer_pass = "catdog"

  module_src_relpath   = split("${get_env("TARGETS_RELPATH")}/", get_original_terragrunt_dir())[1]
  module_relpath_array = split("/", local.module_src_relpath)

  platform_name    = local.module_relpath_array[0]
  environment_name = local.module_relpath_array[1]
  region_name      = local.module_relpath_array[2]
  module_name      = local.module_relpath_array[3]

  environment_descriptor = join("/", [local.platform_name, local.environment_name])
  region_descriptor      = join("/", [local.platform_name, local.environment_name, local.region_name])
  module_descriptor      = join("/", local.module_relpath_array)

  modules_abspath                 = join("/", [get_repo_root(), get_env("MODULES_RELPATH")])
  config_abspath                  = join("/", [get_repo_root(), get_env("CONFIG_RELPATH")])
  kube_artifacts_abspath          = join("/", [get_repo_root(), get_env("KUBE_ARTIFACTS_RELPATH")])
  terragrunt_download_dir_abspath = join("/", [get_repo_root(), get_env("TERRAGRUNT_DOWNLOAD_DIR_RELPATH")])
}
