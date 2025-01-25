set -euo pipefail
bash -version

HOSTS_FILE=/etc/hosts
HOSTS_FILE_BACKUP=/etc/hosts-backup
HOSTS_FILE_TEMP=/etc/hosts-temp

function get_host_ip {
  hosts_gateway_phrase=${1:?'Hosts gateway phrase is required'}

  host_ip=$(cat $HOSTS_FILE | grep $hosts_gateway_phrase | awk '{print $1}')
  exit_code=$?

  if [ "$exit_code" != "0" ]; then
    exit $exit_code
  fi
  : ${host_ip:?'Host ip failed'}

  echo $host_ip
}

function remove_hosts_entries {
  hosts_entries_start_phrase=${1:?'This is required'}
  hosts_entries_end_phrase=${2:?'This is required'}

  cp $HOSTS_FILE $HOSTS_FILE_BACKUP
  sed "/$hosts_entries_start_phrase/,/$hosts_entries_end_phrase/d" $HOSTS_FILE > $HOSTS_FILE_TEMP
  cp $HOSTS_FILE_TEMP $HOSTS_FILE
}

function write_hosts_entries {
  host_ip=${1:?'Host ip is required'}
  hosts_entries=${2:?'Hosts entries are required'}
  hosts_entries_start_phrase=${3:?'This is required'}
  hosts_entries_end_phrase=${4:?'This is required'}

  if [ -z "$host_ip" ]; then
    exit 1
  fi
  echo $hosts_entries_start_phrase >> $HOSTS_FILE
  for host in $hosts_entries; do
    echo "$host_ip $host" >> $HOSTS_FILE
  done
  echo $hosts_entries_end_phrase >> $HOSTS_FILE
}

function display_hosts_file {
  echo "Hosts file:"
  cat $HOSTS_FILE
}
