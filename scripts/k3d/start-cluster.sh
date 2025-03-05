#!/bin/bash

set -euxo pipefail
bash --version

ARGS=(
  cluster_name
  k3d_config_relpath
  k3d_cluster_region
  k3d_cluster_hostname
  k3d_host_volume_root
)
. /home/dev/scripts/utils/parse-args.sh

export K3D_HOST_VOLUME_ROOT="${k3d_host_volume_root}"
export K3D_CLUSTER_REGION="${k3d_cluster_region}"
export K3D_CLUSTER_HOSTNAME="${k3d_cluster_hostname}"

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
  echo "Config file at '${k3d_config_relpath}':"
  cat $k3d_config_relpath | yq

  echo "Creating cluster '$cluster_name'…"
  k3d cluster create -c "$k3d_config_relpath"
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
