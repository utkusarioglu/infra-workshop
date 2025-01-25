locals {
  destroy_cluster_action = "delete" // or stop
  k3d_cluster_region     = "eu-central-1"
  vars                   = read_terragrunt_config(find_in_parent_folders("vars.hcl")).locals

  k3d_cluster_hostname = join(".", [
    local.vars.region_name,
    local.vars.environment_name,
    local.vars.platform_name,
    get_env("CLUSTER_HOSTNAME")
  ])
  k3d_config_relpath = join("/", [local.vars.config_abspath, "k3d.config.yml"])
}

terraform {
  before_hook "k3d_local_start" {
    commands    = ["apply", "plan"]
    working_dir = get_repo_root()
    execute = [
      "scripts/local/start.sh",
      local.vars.devcontainer_pass,
      local.k3d_cluster_hostname
    ]
  }

  before_hook "k3d_check_requirements" {
    commands    = ["apply", "plan"]
    working_dir = get_repo_root()
    execute     = ["scripts/k3d/check-requirements.sh"]
  }

  before_hook "k3d_start_cluster" {
    commands    = ["apply", "plan"]
    working_dir = get_repo_root()
    execute = [
      "scripts/k3d/start-cluster.sh",
      local.vars.cluster_name,
      local.k3d_config_relpath,
      local.vars.module_descriptor,
      local.k3d_cluster_region,
      local.k3d_cluster_hostname
    ]
  }

  after_hook "k3d_stop_cluster" {
    commands    = ["plan", "destroy"]
    working_dir = get_repo_root()
    execute = [
      "k3d",
      "cluster",
      local.destroy_cluster_action,
      local.vars.cluster_name
    ]
  }

  after_hook "local_stop" {
    commands    = ["plan", "destroy"]
    working_dir = get_repo_root()
    execute = [
      "scripts/local/stop.sh",
      local.vars.devcontainer_pass
    ]
  }
}
