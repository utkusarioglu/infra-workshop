#!/bin/bash

set -euo pipefail
bash -version

hosts_gateway_phrase=${1:?'Hosts gateway phrase is required'}
k3d_cluster_hostname=${2:?'K3d cluster hostname is required'}
hosts_entries_start_phrase=${3:?'Host entries start phrase is required'}
hosts_entries_end_phrase=${4:?'Host entries end phrase is required'}

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
