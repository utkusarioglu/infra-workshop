locals {
  constants = {
    MOCKED = "MOCKED"
  }

  _dns = {
    base_domain = "utkusarioglu.com"
    subdomain   = "eks1"
  }
  dns = merge(
    local._dns,
    {
      hostname = join(".", [
        local._dns.subdomain,
        local._dns.base_domain
      ])
    }
  )

  /*
   * Short names are useful for resources such as buckets that have hard
   * limits on filenames
   */
  _region_shorts = {
    "eu-central-1" = "euc1",
    "us-east-1"    = "use1"
    "us-west-1"    = "usw1"
  }
  /*
   * Additional naming values. These are generally used in tags
   */
  _names_extra = {
    cluster       = "infra-workshop"
    cluster_short = "iw"
  }

  /*
   * Secret values that should not be present in the repo
   */
  secret = {
    devcontainer = {
      root_pass = trim(file(join("/", [get_repo_root(), ".secrets", "devcontainer_root_pass"])), "\n")
    }
  }

  /*
   * Resolves details such as the platform, region and unit of the target
   * 
   */
  _relpath_src_targets          = split("${get_env("TARGETS_RELPATH")}/", get_original_terragrunt_dir())[1]
  _relpath_src_targets_segments = split("/", local._relpath_src_targets)
  _relpath_src_targets_names = zipmap(
    ["platform", "environment", "region", "label", "unit"],
    local._relpath_src_targets_segments
  )
  names = merge(
    local._relpath_src_targets_names,
    {
      region_short = try(
        local._region_shorts[local._relpath_src_targets_names.region],
        local._relpath_src_targets_names.region
      ),
    },
    local._names_extra
  )

  _k8s_prefix = "repo.utkusarioglu.com"
  _tags_meta = {
    cluster       = local.names.cluster
    cluster_short = local.names.cluster_short
    platform      = local.names.platform
    region        = local.names.region
    region_short  = local.names.region_short
    environment   = local.names.environment
    label         = local.names.label
    unit          = local.names.unit
  }
  tags = {
    for k, v in local._tags_meta
    : join("", [for s in split("_", k) : title(s)]) => v
  }
  annotations = [
    for k, v in local._tags_meta : {
      key   = join("/", [local._k8s_prefix, join("-", split("_", k))])
      value = v
    }
  ]

  /*
    Paths that are relevant to tg and tf
  */
  abspath = {
    modules = join("/", [get_repo_root(), get_env("MODULES_RELPATH")])
    config  = join("/", [get_repo_root(), get_env("CONFIG_RELPATH")])
    terragrunt = {
      download_dir = join("/", [get_repo_root(), get_env("TERRAGRUNT_DOWNLOAD_DIR_RELPATH")])
    }
    artifacts = {
      base = join("/", [get_repo_root(), "artifacts"])
      kube = join("/", [get_repo_root(), get_env("KUBE_ARTIFACTS_RELPATH")])
    }
    assets = {
      base = join("/", [get_repo_root(), "assets"])
    }
  }

  /*
    These produce identifiers for what region, environment, unit vs the 
    code is acting on
  */
  _id_elements = {
    region = [
      local.names.cluster_short,
      local.names.platform,
      local.names.environment,
      local.names.region_short,
      local.names.label,
    ],
    unit = [
      local.names.cluster_short,
      local.names.platform,
      local.names.environment,
      local.names.region_short,
      local.names.label,
      local.names.unit,
    ],
  }
  id = {
    dash = {
      region = join("-", local._id_elements.region),
      unit   = join("-", local._id_elements.unit),
    }
  }
}

inputs = {
  names       = local.names
  abspath     = local.abspath
  id          = local.id
  secret      = local.secret
  dns         = local.dns
  constants   = local.constants
  tags        = local.tags
  annotations = local.annotations
}
