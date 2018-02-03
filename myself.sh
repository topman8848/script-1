#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/myself.sh | bash

#tools
apt-get install cron wget lrzsz fail2ban -y

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

#hostloc
wget https://raw.githubusercontent.com/mixool/script/master/hostloc.py -O /root/hostloc/hostloc1.py
wget https://raw.githubusercontent.com/mixool/script/master/hostloc.py -O /root/hostloc/hostloc2.py
wget https://raw.githubusercontent.com/mixool/script/master/hostloc.py -O /root/hostloc/hostloc3.py
wget https://raw.githubusercontent.com/mixool/script/master/hostloc.py -O /root/hostloc/hostloc4.py
wget https://raw.githubusercontent.com/mixool/script/master/hostloc.py -O /root/hostloc/hostloc5.py
wget https://raw.githubusercontent.com/mixool/script/master/hostloc.py -O /root/hostloc/hostloc.py

#bilibiliHelper
wget https://github.com/mixool/script/raw/source/Bilibili.php -O /root/BilibiliHelper/Bilibili.php
wget https://github.com/mixool/script/raw/source/Bilibilirun.php -O /root/BilibiliHelper/index.php

#/etc/crontab
echo "1 0 * * * root python /root/hostloc/hostloc1.py" >> /etc/crontab
echo "2 0 * * * root python /root/hostloc/hostloc2.py" >> /etc/crontab
echo "3 0 * * * root python /root/hostloc/hostloc3.py" >> /etc/crontab
echo "4 0 * * * root python /root/hostloc/hostloc4.py" >> /etc/crontab
echo "5 0 * * * root python /root/hostloc/hostloc5.py" >> /etc/crontab
echo "#" >> /etc/crontab
echo "3 0 * * * root php /root/BilibiliHelper/index.php > /root/BilibiliHelper/log.txt" >> /etc/crontab
echo "#" >> /etc/crontab

#Informations
clear
date
echo "All done!"
