locals {
  # parents = read_terragrunt_config("./logic.target.k3d.helper.hcl").locals.parents

  # cluster_name = local.parents.region.locals.cluster_name
  cluster_name = "infra-workshop"

  k3d_config_path        = "${get_repo_root()}/src/config/k3d.config.yml"
  destroy_cluster_action = "delete" // or stop
}

terraform {
  # before_hook "check_requirements" {
  #   commands = [
  #     "apply",
  #     "plan"
  #   ]
  #   execute = [
  #     "scripts/check-requirements.sh",
  #     "${get_repo_root()}"
  #   ]
  # }
  before_hook "local_start" {
    working_dir = get_repo_root()
    commands = [
      "apply",
      "plan"
    ]
    execute = [
      "scripts/local/start.sh",
      "catdog"
    ]
  }

  before_hook "start_k3d_cluster" {
    commands = [
      "apply",
      "plan"
    ]
    execute = [
      "scripts/start-k3d-cluster.sh",
      local.cluster_name,
      local.k3d_config_path
    ]
  }

  # // Needed by Vault 
  # after_hook "retrieve_ca_crt_file" {
  #   commands = ["plan", "apply"]
  #   execute = [
  #     "scripts/kubectl-get-cluster-ca.sh",
  #     "${get_repo_root()}/artifacts/cluster-ca/cluster-ca.crt"
  #   ]
  # }

  after_hook "stop_k3d_cluster" {
    commands = [
      "plan",
      "destroy"
    ]
    working_dir = "${get_repo_root()}/src/config"
    execute = [
      "k3d",
      "cluster",
      local.destroy_cluster_action,
      local.cluster_name
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
      "catdog"
    ]
  }
}
