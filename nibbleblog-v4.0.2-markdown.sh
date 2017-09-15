#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/nibbleblog-v4.0.2-markdown.sh | bash

export URL="http://sourceforge.net/projects/nibbleblog/files/v4.0/nibbleblog-v4.0.2-markdown.zip"

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

echo "1. Install updating"
apt-get update
apt-get install apache2 unzip php5-common libapache2-mod-php5  php5-gd php5-mcrypt -y
clear

echo "2. Download nibbleblog-markdown from $RINET_URL and setup"
rm -rf /var/www/html/*
curl -L "${URL}" >/var/www/html/nibbleblog-markdown.zip
unzip /var/www/html/nibbleblog-markdown.zip
sleep 10
mv /var/www/html/nibbleblog-markdown/* /var/www/html/
rm -rf /var/www/html/nibbleblog-markdown /var/www/html/index.html /var/www/html/nibbleblog-markdown.zip
chmod 777 /var/www/html/content
service apache2 restart

echo "3. Congratulations, nibbleblog-markdown install completed!"
