#!/bin/bash

set -euo pipefail
bash --version

cluster_name=${1:?'Cluster name needs to be param #1'}
cluster_config_path=${2:?'Cluster config path needs to be param #2'}
host_volume_relpath=${3:?'Host volumes relpath needs to be param #3'}

: ${HOST_ROOT:?'This environment variable needs to be set'}
: ${HOST_VOLUME_RELPATH:?'This environment variable needs to be set'}

repo_volume_relpath="${HOST_VOLUME_RELPATH}/${host_volume_relpath}"
mkdir -p ${repo_volume_relpath}

terragrunt_host_volume_root=${HOST_ROOT}/${repo_volume_relpath}

export TERRAGRUNT_HOST_VOLUME_ROOT=${terragrunt_host_volume_root}

clusters=$(k3d cluster list -o json)
matching_clusters=$(echo $clusters | jq -r '
  [
    .[] | select(.name | . == "'$cluster_name'") 
  ]
')
cluster_count=$(echo "$matching_clusters" | jq -r 'length')

if [ $cluster_count -gt 1 ]; then
  echo "Error: Given cluster name matches more than one cluster."
  echo "Halting operation to prevent data loss."
  exit 2
elif [ $cluster_count -lt 1 ]; then
  echo "Creating cluster '$cluster_name'…"
  k3d cluster create -c "$cluster_config_path"
  exit 0 
fi

cluster_servers_running=$(echo $matching_clusters | jq -r '.[0].serversRunning')
cluster_agents_running=$(echo $matching_clusters | jq -r '.[0].agentsRunning')

# @dev 
# code here may need to check whether the cluster has failing nodes, 
# ie: running node count that is more than 0 but less than the values in 
# `serversCount` or `agentsCount` in k3d output.

if [ $cluster_servers_running -eq 0 ] && [ $cluster_agents_running -eq 0 ]; then
  echo "Starting cluster '$cluster_name'…"
  k3d cluster start "$cluster_name"
fi
