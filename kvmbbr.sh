#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/kvmbbr.sh | bash

# Make sure only root can run this script
[[ $EUID -ne 0 ]] && echo "Error, This script must be run as root!" && exit 1

cat <<EOF > /etc/apt/sources.list.d/jessie-backports.list
deb http://archive.debian.org/debian jessie-backports main
deb http://archive.debian.org/debian jessie-backports-sloppy main
EOF

apt -o Acquire::Check-Valid-Until=false update
apt-get -t jessie-backports install linux-image-amd64 -y

echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
sysctl -p

echo "OK!!! Then please reboot system to enable BBR."
