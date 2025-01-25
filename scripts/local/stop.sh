#!/bin/bash

set -euo pipefail
bash --version

ENVS=(
  HOSTS_ENTRIES_START_PHRASE
  HOSTS_ENTRIES_END_PHRASE
)
. /home/dev/scripts/utils/check-envs.sh
ARGS=(
  root_pass
)
. /home/dev/scripts/utils/parse-args.sh

current_dir=$(pwd)

docker_host_and_group=1001:1001

su - <<EOT
${root_pass}

echo "Altering docker.sock ownership…"
chown ${docker_host_and_group} /var/run/docker.sock

cd ${current_dir}
echo "Adding hosts entries…"
scripts/hosts/remove.sh \
  "${HOSTS_ENTRIES_START_PHRASE}" \
  "${HOSTS_ENTRIES_END_PHRASE}"
EOT

echo "Done."
