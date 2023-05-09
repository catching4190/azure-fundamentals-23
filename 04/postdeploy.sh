#!/bin/bash
echo apt-key add -
apt-get -y update
apt-get -y install nginx
apt-get -y install unzip
wget -O /tmp/app.zip https://github.com/catching4190/azure-fundamentals-23/raw/task-4/04/app.zip
wget -O /etc/nginx/nginx.conf https://github.com/catching4190/azure-fundamentals-23/raw/task-4/04/nginx.conf
unzip /tmp/app.zip -d /tmp
systemctl enable nginx
systemctl start nginx
