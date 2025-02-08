#!/bin/bash

exec > /var/log/user-data.log 2>&1

sudo amazon-linux-extras install nginx1 -y

echo "aws - $(date)" | sudo tee /usr/share/nginx/html/index.html

sudo systemctl restart nginx
