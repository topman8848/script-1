#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/kvm-bbr.sh | bash

# Make sure only root can run this script
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

#Install bbr 
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.16/linux-image-4.16.0-041600-generic_4.16.0-041600.201804012230_amd64.deb
dpkg -i linux-image-4.16.0-041600-generic_4.16.0-041600.201804012230_amd64.deb
rm linux-image-4.16.0-041600-generic_4.16.0-041600.201804012230_amd64.deb

echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
sysctl -p >/dev/null 2>&1
/usr/sbin/update-grub

read -p "The system needs to reboot.Do you want to restart system? [y/n]" is_reboot </dev/tty

if [[ ${is_reboot} == "y" || ${is_reboot} == "Y" ]]; then
        echo "Rebooting..."
        reboot
    else
        echo "Reboot has been canceled..."
        exit 0
    fi
