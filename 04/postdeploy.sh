#!/bin/bash
echo apt-key add -
sudo apt-get -y update
sudo apt-get -y install nginx
sudo apt-get install unzip
wget -O ~/app.zip https://github.com/catching4190/azure-fundamentals-23/raw/d0b30d87b46ad69beabad5901c2c4286496f9899/04/app.zip
unzip app.zip
sudo wget -O /etc/nginx/nginx.conf https://github.com/catching4190/azure-fundamentals-23/raw/1941f4b7c7350a1e75b1c56faedf91599cac2f81/04/nginx.conf
sudo systemctl enable nginx
sudo systemctl start nginx
