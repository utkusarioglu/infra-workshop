#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Rerunning with sudo"
  exec sudo bash "$0" "$@"
fi

set -euo pipefail

exec > /var/log/user-data.log 2>&1

amazon-linux-extras install nginx1 epel -y
yum install -y certbot

systemctl start nginx

certbot certonly \
  --noninteractive \
  --agree-tos \
  --webroot \
  -w /usr/share/nginx/html \
  -d ${domain_name} \
  --email ${email_address}

echo "0 0 * * * root certbot renew --quiet" > /etc/cron.d/certbot-renew

aws s3 cp s3://${bucket_name}/index.html /usr/share/nginx/html/index.html
aws s3 cp s3://${bucket_name}/nginx.conf /etc/nginx/nginx.conf

systemctl restart nginx
