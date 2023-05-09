#!/bin/bash
echo apt-key add -
sudo apt-get -y update
sudo apt-get -y install nginx
sudo apt-get install unzip
wget -O ~/app.zip https://github.com/catching4190/azure-fundamentals-23/raw/d0b30d87b46ad69beabad5901c2c4286496f9899/04/app.zip
wget -O /etc/nginx/nginx.conf https://github.com/catching4190/azure-fundamentals-23/raw/d0b30d87b46ad69beabad5901c2c4286496f9899/04/nginx.conf
unzip app.zip
sudo systemctl enable nginx
sudo systemctl start nginx
