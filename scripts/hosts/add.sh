#!/bin/bash

set -euo pipefail
bash -version

ENVS=(
  CLUSTER_HOSTNAME
)
. /home/dev/scripts/utils/check-envs.sh
ARGS=(
  hosts_gateway_phrase
  k3d_cluster_hostname
  hosts_entries_start_phrase
  hosts_entries_end_phrase
)
. /home/dev/scripts/utils/parse-args.sh

hosts_entries="
${CLUSTER_HOSTNAME}
${k3d_cluster_hostname}
"

if [ -z "$hosts_gateway_phrase" ]; then
  echo "Error: hosts_gateway_phrase is required to define hosts entries"
  exit 1
fi

source ${0%/*}/common.sh

host_ip=$(get_host_ip $hosts_gateway_phrase)

echo "Config:"
echo "Host ip: $host_ip"
echo "Start phrase: $hosts_entries_start_phrase"
echo "End phrase: $hosts_entries_end_phrase"
echo "Host gateway phrase: $hosts_gateway_phrase"
echo "Hosts entries: ${hosts_entries}"

remove_hosts_entries \
  "${hosts_entries_start_phrase}" \
  "${hosts_entries_end_phrase}"

write_hosts_entries \
  "${host_ip}" \
  "${hosts_entries}" \
  "${hosts_entries_start_phrase}" \
  "${hosts_entries_end_phrase}"
  
exit_code=$?
if [ "$exit_code" != "0" ]; then
  echo "Error: failed to write hosts entries"
  exit $exit_code
fi

echo
display_hosts_file
