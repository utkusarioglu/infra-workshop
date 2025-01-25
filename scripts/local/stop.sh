#!/bin/bash

set -euo pipefail
bash --version

msg='This environment variable is required'
: ${HOSTS_ENTRIES_START_PHRASE:?$msg}
: ${HOSTS_ENTRIES_END_PHRASE:?$msg}

root_pass="${1:?'Root password required'}"

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
