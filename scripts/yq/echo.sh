#!/bin/bash

set -uo pipefail

ARGS=(
  yaml
)
. /home/dev/scripts/utils/parse-args.sh

echo "${yaml}" | yq -P
