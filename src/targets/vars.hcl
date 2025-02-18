locals {
  module_src_relpath          = split("${get_env("TARGETS_RELPATH")}/", get_original_terragrunt_dir())[1]
  module_src_relpath_segments = split("/", local.module_src_relpath)
  module_src_relpath_names = zipmap(
    ["platform", "environment", "region", "label", "unit"],
    local.module_src_relpath_segments
  )
  region_shorts = {
    "eu-central-1" = "euc1",
    "us-east-1"    = "use1"
    "us-west-1"    = "usw1"
  }
}

inputs = {
  devcontainer_pass = "catdog"

  /*
    These produce identifiers for what region, environment, unit vs the 
    code is acting on
  */
  module_src_relpath = local.module_src_relpath
  names = merge(
    local.module_src_relpath_names,
    {
      region_short = try(
        local.region_shorts[local.module_src_relpath_names.region],
        local.module_src_relpath_names.region
      )
      cluster       = "infra-workshop"
      cluster_short = "iw"
    }
  )

  /*
    Paths that are relevant to tg and tf
  */
  abspath = {
    modules                 = join("/", [get_repo_root(), get_env("MODULES_RELPATH")])
    config                  = join("/", [get_repo_root(), get_env("CONFIG_RELPATH")])
    terragrunt_download_dir = join("/", [get_repo_root(), get_env("TERRAGRUNT_DOWNLOAD_DIR_RELPATH")])
    artifacts = {
      base = join("/", [get_repo_root(), "artifacts"])
      kube = join("/", [get_repo_root(), get_env("KUBE_ARTIFACTS_RELPATH")])
    }
  }
}
