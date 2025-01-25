#!/bin/bash

set -euo pipefail
bash --version

artifact_file=${1:?'Artifact file is required'}

if [ -z "$artifact_file" ]; then
  echo "Error: artifacts file path needs to be the first param"
  exit 1
fi

cluster_ca_crt_string=$(kubectl config view --minify --flatten \
  | yq '.clusters.0.cluster.certificate-authority-data' \
  | base64 --decode
)

echo "Creating '$artifact_file' file..."
mkdir -p "${artifact_file%/*}/"
touch "$artifact_file"
echo "$cluster_ca_crt_string" > "$artifact_file"
