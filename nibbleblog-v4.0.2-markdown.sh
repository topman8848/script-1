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
cd /var/www/html
wget --no-check-certificate "${URL}"
unzip nibbleblog-v4.0.2-markdown.zip
mv ./nibbleblog-markdown/* ./
chmod 777 content
rm -rf nibbleblog-markdown nibbleblog-v4.0.2-markdown.zip index.html
service apache2 restart

echo "3. Congratulations, nibbleblog-markdown install completed!"
