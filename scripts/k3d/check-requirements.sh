#!/bin/bash

set -euo pipefail
bash --version


ENVS=(
  HOSTS_ENTRIES_START_PHRASE
  HOSTS_ENTRIES_END_PHRASE
)
. /home/dev/scripts/utils/check-envs.sh

function check_docker_sock_ownership {
  docker_sock_path=/var/run/docker.sock
  if [[ ! -O "$docker_sock_path" ]]; then
    echo "Error: Docker permissions have not been adjusted."
    return 1
  fi
}

function check_hosts_entries {
  hosts_file_path=/etc/hosts
  hosts_list_start=$(
    cat "$hosts_file_path" \
    | grep "$HOSTS_ENTRIES_START_PHRASE"
  )
  if [ -z "$hosts_list_start" ]; then
    echo "Error: host entries missing"
    return 2
  fi
  hosts_list_end=$(
    cat "$hosts_file_path" \
    | grep "$HOSTS_ENTRIES_END_PHRASE"
  )
  if [ -z "$hosts_list_end" ]; then
    echo "Error: Missing hosts entries end. May imply bug."
    return 3
  fi
}

function check_all {
  echo "Starting checks…"
  err_state=0
  check_docker_sock_ownership
  err_state=$(( $err_state + $? ))
  check_hosts_entries
  err_state=$((err_state + $?))

  if (( $err_state != 0 )); then
    echo 
    echo 'Some checks resulted in errors'
    echo 'Did `scripts/local/start.sh` fail to run?'
  fi
  return $err_state
}

check_all
