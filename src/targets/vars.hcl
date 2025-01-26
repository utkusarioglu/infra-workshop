locals {
  cluster_name      = "infra-workshop"
  cluster_code      = "iw"
  devcontainer_pass = "catdog"

  /*
    These produce identifiers for what region, environment, unit vs the 
    code is acting on
  */
  region_shorts = {
    "eu-central-1" = "euc1",
    "us-east-1"    = "use1"
    "us-west-1"    = "usw1"
  }
  module_src_relpath          = split("${get_env("TARGETS_RELPATH")}/", get_original_terragrunt_dir())[1]
  module_src_relpath_segments = split("/", local.module_src_relpath)
  module_src_relpath_names    = zipmap(["platform", "environment", "region", "unit"], local.module_src_relpath_segments)
  names = merge(
    local.module_src_relpath_names,
    {
      region_short = local.region_shorts[local.module_src_relpath_names.region]
    }
  )

  /*
    Paths that are relevant to tg and tf
  */
  modules_abspath                 = join("/", [get_repo_root(), get_env("MODULES_RELPATH")])
  config_abspath                  = join("/", [get_repo_root(), get_env("CONFIG_RELPATH")])
  kube_artifacts_abspath          = join("/", [get_repo_root(), get_env("KUBE_ARTIFACTS_RELPATH")])
  terragrunt_download_dir_abspath = join("/", [get_repo_root(), get_env("TERRAGRUNT_DOWNLOAD_DIR_RELPATH")])
}
