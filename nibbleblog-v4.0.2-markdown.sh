#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/nibbleblog-v4.0.2-markdown.sh | bash

export green='\033[0;32m'
export plain='\033[0m'

export URL="https://raw.githubusercontent.com/mixool/script/source/nibbleblog-v4.0.2-markdown.zip"


if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

echo -e "${green}Install dependencies${plain}"
apt-get update
apt-get install apache2 unzip php5-common libapache2-mod-php5  php5-gd php5-mcrypt -y
service apache2 restart
clear

echo "Make sure libapache2-mod-php5 installed"
apt-get remove --purge php5 -y
apt-get remove --purge libapache2-mod-php5 -y
apt-get install php5 -y
apt-get install libapache2-mod-php5 -y
service apache2 restart

echo -e "${green}Download nibbleblog-markdown from $URL and installation${plain}"
rm -rf /var/www/html
cd /var/www
wget --no-check-certificate "${URL}"
unzip nibbleblog-v4.0.2-markdown.zip
rm -rf nibbleblog-v4.0.2-markdown.zip
mv nibbleblog-markdown html
chmod 777 /var/www/html/content
clear

echo -e "${green}Congratulations, nibbleblog-markdown install completed!${plain}"
