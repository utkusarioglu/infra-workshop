#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Rerunning with sudo"
  exec sudo bash "$0" "$@"
fi

set -uexo pipefail

exec > /var/log/user-data.log 2>&1

mkdir /provisioning
cd /provisioning

echo ${bucket_id} > /provisioning/bucket_id
echo ${domain_name} > /provisioning/domain_name
echo ${email_address} > /provisioning/email_address

aws s3 cp s3://${bucket_id}/provisioning.sh /provisioning/run.sh
chmod +x /provisioning/run.sh

/provisioning/run.sh
