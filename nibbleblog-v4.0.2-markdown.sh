#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/nibbleblog-v4.0.2-markdown.sh | bash

export URL="https://raw.githubusercontent.com/mixool/script/source/nibbleblog-v4.0.2-markdown.zip"

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

echo "Install updating"
apt-get update
apt-get install apache2 unzip php5-common libapache2-mod-php5  php5-gd php5-mcrypt -y
service apache2 restart
clear

echo "Download nibbleblog-markdown from $RINET_URL and setup"
rm -rf /var/www/html
cd /var/www
wget --no-check-certificate "${URL}"
unzip nibbleblog-v4.0.2-markdown.zip
rm -rf nibbleblog-v4.0.2-markdown.zip
mv nibbleblog-markdown html
chmod 777 /var/www/html/content
clear

echo "Congratulations, nibbleblog-markdown install completed!"
