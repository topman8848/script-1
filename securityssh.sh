#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/debian-9/securityssh.sh | bash

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

# Informations
read -p "Please input ssh port:" port </dev/tty
read -p "Please input the public key:" key </dev/tty

# Add key
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo $key >> ~/.ssh/authorized_keys

# Config 
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_bak
echo -e "Port ${port}" >> /etc/ssh/sshd_config
sed -i "s/PermitRootLogin.*/PermitRootLogin without-password/g" /etc/ssh/sshd_config

# Active
systemctl reload sshd.service
