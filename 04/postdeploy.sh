#!/bin/bash
echo apt-key add -
apt-get -y update
apt-get -y install nginx
apt-get -y install unzip
wget -O ~/app.zip https://github.com/catching4190/azure-fundamentals-23/raw/d0b30d87b46ad69beabad5901c2c4286496f9899/04/app.zip
wget -O /etc/nginx/nginx.conf https://github.com/catching4190/azure-fundamentals-23/raw/1941f4b7c7350a1e75b1c56faedf91599cac2f81/04/nginx.conf
unzip app.zip
systemctl enable nginx
systemctl start nginx
