#!/bin/bash
# Usage:
#  wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/master/sources.sh && chmod +x sources.sh && ./sources.sh

[[ $EUID -ne 0 ]] && echo "Error, This script must be run as root!" && exit 1

cat <<EOF > /etc/apt/sources.list
deb http://archive.debian.org/debian/ jessie main
deb-src http://archive.debian.org/debian/ jessie main

deb http://security.debian.org jessie/updates main
deb-src http://security.debian.org jessie/updates main
EOF

apt-get clean
apt-get update
