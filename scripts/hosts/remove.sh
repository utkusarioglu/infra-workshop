#!/bin/bash

set -euo pipefail
bash --version

hosts_entries_start_phrase=${1:?'Host entries start phrase is required'}
hosts_entries_end_phrase=${2:?'Host entries end phrase is required'}

source ${0%/*}/common.sh

remove_hosts_entries \
  "${hosts_entries_start_phrase}" \
  "${hosts_entries_end_phrase}"

display_hosts_file
