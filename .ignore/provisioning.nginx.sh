#!/bin/bash

exec > /var/log/user-data.log 2>&1

sudo amazon-linux-extras install nginx1 epel -y
sudo yum install -y certbot

systemctl start nginx

sudo certbot certonly \
  --noninteractive \
  --agree-tos \
  --webroot \
  -w /usr/share/nginx/html \
  -d ${domain_name} \
  --email ${email_address}

sudo sh -c 'echo "0 0 * * * root certbot renew --quiet" > /etc/cron.d/certbot-renew'

sudo aws s3 cp s3://${bucket}/index.html /usr/share/nginx/html/index.html
sudo aws s3 cp s3://${bucket}/nginx.conf /etc/nginx/nginx.conf

sudo systemctl restart nginx
