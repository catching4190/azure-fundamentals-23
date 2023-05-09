#!/bin/bash
echo apt-key add -
sudo apt-get -y update
sudo apt-get -y install nginx
sudo apt-get install unzip
wget -O /tmp/app.zip https://github.com/catching4190/azure-fundamentals-23/raw/5b918c636b5df6094ca6f49bc7514f5f36a799c7/04/app.zip
sudo unzip /tmp/app.zip -o -d /
sudo systemctl enable nginx
sudo systemctl start nginx
