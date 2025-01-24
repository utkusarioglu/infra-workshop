include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  k3d_config_path        = join("/", [include.root.locals.config_abspath, "k3d.config.yml"])
  destroy_cluster_action = "delete" // or stop
}

terraform {
  before_hook "k3d_local_start" {
    commands = [
      "apply",
      "plan"
    ]
    working_dir = get_repo_root()
    execute = [
      "scripts/local/start.sh",
      include.root.locals.devcontainer_pass
    ]
  }

  before_hook "k3d_check_requirements" {
    working_dir = get_repo_root()
    commands = [
      "apply",
      "plan"
    ]
    execute = [
      "scripts/k3d/check-requirements.sh"
    ]
  }

  before_hook "k3d_start_cluster" {
    commands = [
      "apply",
      "plan"
    ]
    working_dir = get_repo_root()
    execute = [
      "scripts/k3d/start-cluster.sh",
      include.root.locals.cluster_name,
      local.k3d_config_path,
      include.root.locals.module_path
    ]
  }

  // Needed by Vault 
  after_hook "kube_get_cluster_ca" {
    commands = [
      "plan",
      "apply"
    ]
    working_dir = get_repo_root()
    execute = [
      "scripts/kube/get-cluster-ca.sh",
      // I don't know what to do about this yet
      // there may not be enough such files to warrant a separate env var
      "${get_repo_root()}/artifacts/kube/cluster-ca.crt"
    ]
  }

  after_hook "k3d_stop_cluster" {
    commands = [
      "plan",
      "destroy"
    ]
    working_dir = get_repo_root()
    execute = [
      "k3d",
      "cluster",
      local.destroy_cluster_action,
      include.root.locals.cluster_name
    ]
  }

  after_hook "local_stop" {
    working_dir = get_repo_root()
    commands = [
      "plan",
      "destroy"
    ]
    execute = [
      "scripts/local/stop.sh",
      include.root.locals.devcontainer_pass
    ]
  }
}
