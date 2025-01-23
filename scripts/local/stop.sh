#!/bin/bash

root_pass="${1:?'Root password required'}"
current_dir=$(pwd)
docker_host_and_group=1001:1001

su - <<EOT
${root_pass}

echo "Altering docker.sock ownership…"
chown ${docker_host_and_group} /var/run/docker.sock

cd ${current_dir}
echo "Adding hosts entries…"
scripts/hosts-entries/remove.sh host-gateway
EOT

echo "Done."
