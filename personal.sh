#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/personal.sh | bash

read -p "Input url: " URL </dev/tty
#read -p "Save as: " SA </dev/tty

curl -k  $URL | grep -oE "ssr?://\w{18,}" | sort -u
#curl -k  $URL | grep -oE "ssr?://\w{18,}" | sort -u >>$SA
#grep -oE "ssr?://\w{18,}" | awk -F"Jmdyb3VwP|mZ3JvdXA9|cm91cD" '{print $1}' | sort -u

# Crontab
#(crontab -l ; echo -e "0 * * * * curl -k  $URL | grep -oE "ssr?://\w{18,}" | sort -u >>$SA") | crontab -
