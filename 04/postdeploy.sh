#!/bin/bash
echo apt-key add -
sudo apt-get -y update
sudo apt-get -y install nginx
sudo apt-get -y install unzip
sudo systemctl enable nginx
sudo systemctl start nginx
sudo wget -O /tmp/app.zip https://github.com/catching4190/azure-fundamentals-23/raw/main/04/app.zip
sudo wget -O /etc/nginx/nginx.conf https://github.com/catching4190/azure-fundamentals-23/raw/main/04/nginx.conf
sudo unzip /tmp/app.zip -d /tmp
sudo nginx -s reload
