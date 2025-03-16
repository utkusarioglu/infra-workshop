#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Rerunning with sudo"
  exec sudo bash "$0" "$@"
fi

set -uex

cd /provisioning 

bucket_id="$(cat bucket_id)"
domain_name="$(cat domain_name)"
email_address="$(cat email_address)"

le='/etc/letsencrypt'
le_live="${le}/live/${domain_name}"
le_archive="${le}/archive/${domain_name}"

amazon-linux-extras enable docker epel
yum install -y docker epel-release
yum install -y certbot

systemctl enable --now docker
usermod -aG docker ec2-user

docker run \
  -d \
  --rm \
  -v "${PWD}:/usr/share/nginx/html" \
  --name nginx-80 \
  --network host \
  nginx

certbot certonly \
  --noninteractive \
  --agree-tos \
  --webroot \
  -w ${PWD} \
  -d ${domain_name} \
  --email ${email_address}

docker container stop nginx-80

aws s3 cp "s3://${bucket_id}/index.html" "${PWD}/index.html"
aws s3 cp "s3://${bucket_id}/nginx.conf" "${PWD}/nginx.conf"

docker run \
  --name nginx-443 \
  --restart always \
  -v "${PWD}/index.html:/usr/share/nginx/html/index.html" \
  -v "${PWD}/nginx.conf:/etc/nginx/nginx.conf" \
  -v "${le_archive}/fullchain1.pem:/certs/fullchain.pem" \
  -v "${le_archive}/privkey1.pem:/certs/privkey.pem" \
  --network host \
  nginx
