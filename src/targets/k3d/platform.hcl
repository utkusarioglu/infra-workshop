locals {
  destroy_cluster_action = "delete" // or stop
  k3d_cluster_region     = "eu-central-1"

  inputs = read_terragrunt_config(find_in_parent_folders("vars.hcl")).inputs

  k3d_cluster_hostname = join(".", [
    local.inputs.names.region,
    local.inputs.names.environment,
    local.inputs.names.platform,
    get_env("CLUSTER_HOSTNAME")
  ])
  k3d_config_relpath = join("/", [local.inputs.abspath.config, "k3d.config.yml"])
}

terraform {
  before_hook "k3d_local_start" {
    commands    = ["apply", "plan"]
    working_dir = get_repo_root()
    execute = [
      "scripts/local/start.sh",
      local.inputs.devcontainer_pass,
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
      local.inputs.names.cluster,
      local.k3d_config_relpath,
      local.inputs.module_src_relpath,
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
      local.inputs.names.cluster
    ]
  }

  after_hook "local_stop" {
    commands    = ["plan", "destroy"]
    working_dir = get_repo_root()
    execute = [
      "scripts/local/stop.sh",
      local.inputs.devcontainer_pass
    ]
  }
}
