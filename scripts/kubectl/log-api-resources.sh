#!/bin/bash

# set -euo pipefail

ARGS=(
  cluster_id
  sleep_seconds
)
. /home/dev/scripts/utils/parse-args.sh

echo "Sleeping for ${sleep_seconds}s…"
sleep $sleep_seconds

date_code=$(date '+%Y-%m-%d-%H-%M-%S')
resource_names=$(kubectl api-resources | awk '{print $1}' | tail -n +2)

artifacts_relpath="artifacts/kubectl/${cluster_id}/${date_code}"
mkdir -p "${artifacts_relpath}"

for resource in ${resource_names[@]}; do
  echo $resource
  kubectl describe $resource -A > "${artifacts_relpath}/$resource.log"
done
