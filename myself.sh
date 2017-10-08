#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/myself.sh | bash

#tools
apt-get install cron curl wget lrzsz -y

#php
apt-get install php5-common  php5-cli -y
apt-get install php5-gd php5-curl -y

#python
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
pip install requests beautifulsoup4
rm get-pip.py

#timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#mkdir 
mkdir /root/hostloc
mkdir /root/BilibiliHelper
mkdir /root/BilibiliHelper/log.txt

#hostloc
wget https://raw.githubusercontent.com/mixool/script/master/hostloc.py -O /root/hostloc/hostloc.py
wget https://raw.githubusercontent.com/mixool/script/master/hostloc.py -O /root/hostloc/hostmoc.py
wget https://raw.githubusercontent.com/mixool/script/master/hostloc.py -O /root/hostloc/hostxoc.py

#bilibiliHelper
wget https://github.com/mixool/script/raw/source/Bilibili.php -O /root/BilibiliHelper/Bilibili.php
wget https://github.com/mixool/script/raw/source/Bilibilirun.php -O /root/BilibiliHelper/index.php

#/etc/crontab
echo "1 0 * * * root python /root/hostloc/hostloc.py" >> /etc/crontab
echo "2 0 * * * root python /root/hostloc/hostmoc.py" >> /etc/crontab
echo "4 0 * * * root python /root/hostloc/hostxoc.py" >> /etc/crontab
echo "#" >> /etc/crontab
echo "3 0 * * * root php /root/BilibiliHelper/index.php > /root/BilibiliHelper/log.txt" >> /etc/crontab
echo "#" >> /etc/crontab
echo -e "30 */4 * * * root curl -X POST \"https://openapi.daocloud.io/v1/apps/ae20ae7b-5ddd-42d7-b7d4-e761533e9e40/actions/redeploy\" -H \"Authorization: token 3od80jtlyaaiw4s024s77oprj7ttcukq6eqh5wp4\" -H \"Content-Type: application/json\" -d '{\"release_name\": \"latest\"}'" >> /etc/crontab
echo "#" >> /etc/crontab

#Informations
echo "All done!"
