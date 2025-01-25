#!/bin/bash

set -euo pipefail
bash --version

msg='This environment variable is required'
: ${HOST_GATEWAY_PHRASE:?$msg}
: ${HOSTS_ENTRIES_START_PHRASE:?$msg}
: ${HOSTS_ENTRIES_END_PHRASE:?$msg}

root_pass="${1:?'Root password required'}"
k3d_cluster_hostname=${2:?'K3d cluster hostname is required'}

current_dir=$(pwd)

su - <<EOT
${root_pass}

echo "Altering docker.sock ownership…"
chown $(id -u):$(id -g) /var/run/docker.sock

cd ${current_dir}
echo "Adding hosts entries…"
scripts/hosts/add.sh \
  "${HOST_GATEWAY_PHRASE}" \
  "${k3d_cluster_hostname}" \
  "${HOSTS_ENTRIES_START_PHRASE}" \
  "${HOSTS_ENTRIES_END_PHRASE}"
EOT
