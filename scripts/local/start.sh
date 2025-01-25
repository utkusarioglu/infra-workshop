#!/bin/bash

set -euo pipefail
bash --version

ENVS=(
  HOST_GATEWAY_PHRASE
  HOSTS_ENTRIES_START_PHRASE
  HOSTS_ENTRIES_END_PHRASE
)
. /home/dev/scripts/utils/check-envs.sh
ARGS=(
  root_pass
  k3d_cluster_hostname
)
. /home/dev/scripts/utils/parse-args.sh

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

echo "Done."
