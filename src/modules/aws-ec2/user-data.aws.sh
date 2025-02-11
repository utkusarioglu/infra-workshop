#!/bin/bash

exec > /var/log/user-data.log 2>&1

sudo amazon-linux-extras install nginx1 -y

sudo aws s3 cp s3://infra-workshop-aws-dev-s3-bucket/index.html /usr/share/nginx/html/index.html
# echo "aws - $(date)" | sudo tee /usr/share/nginx/html/index.html

sudo systemctl restart nginx
