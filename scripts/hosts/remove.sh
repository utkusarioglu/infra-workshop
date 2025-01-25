#!/bin/bash

set -euo pipefail
bash --version

ARGS=(
  hosts_entries_start_phrase
  hosts_entries_end_phrase
)
. /home/dev/scripts/utils/parse-args.sh

source ${0%/*}/common.sh

remove_hosts_entries \
  "${hosts_entries_start_phrase}" \
  "${hosts_entries_end_phrase}"

display_hosts_file
