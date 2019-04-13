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
sysctl -p >/dev/null 2>&1

uname -r

cat /etc/sysctl.conf

sysctl net.ipv4.tcp_available_congestion_control

sysctl net.ipv4.tcp_congestion_control

read -p "The system needs to reboot.Do you want to restart system? [y/n]" is_reboot </dev/tty

if [[ ${is_reboot} == "y" || ${is_reboot} == "Y" ]]; then
        echo "Rebooting..."
        reboot
    else
        echo "Reboot has been canceled..."
        exit 0
    fi
