#!/bin/bash

set -euo pipefail

ARGS=(
  region
  cluster_name
  profile
)
. /home/dev/scripts/utils/parse-args.sh

standard_args="--profile ${profile} --region ${region}"
volume_filter="Name=tag:KubernetesCluster,Values=${cluster_name}"

volumes_json=$(aws ec2 describe-volumes ${standard_args} --filter $volume_filter) 
volumes_id=$(echo $volumes_json | jq -r '.Volumes[].VolumeId')

for volume_id in ${volumes_id[@]}; do
  echo "Deleting: ${volume_id}…"
  aws ec2 delete-volume ${standard_args} --volume-id $volume_id 
done
