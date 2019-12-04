#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/debian-9/securityssh.sh | bash

[[ "$(id -u)" != "0" ]] && echo "ERROR: Please run as root" && exit 1

# custom port
echo "Securing your SSH server with custom port..."
SSH_PORT=${SSH_PORT:-n}
while ! [[ ${SSH_PORT} =~ ^[0-9]+$ ]]; do
    read -p "Custom SSH port (default SSH port is 22): " -e SSH_PORT
done

if [[ ${SSH_PORT} =~ ^[0-9]+$ ]]; then
    if grep -qwE "^Port\ [0-9]*" /etc/ssh/sshd_config; then
        sed -i "s/^Port\ [0-9]*/Port\ ${SSH_PORT}/g" /etc/ssh/sshd_config
    else
        sed -i "/^#Port\ [0-9]*/a Port\ ${SSH_PORT}" /etc/ssh/sshd_config
    fi
	echo "SSH port updated to ${SSH_PORT}."
else
    echo "Unable to update SSH port."
fi

# custom rsa_pub_key login
RSA_PUB_KEY=${RSA_PUB_KEY:-n}
while ! [[ ${RSA_PUB_KEY} =~ ssh-rsa* ]]; do
    read -p ": " -e RSA_PUB_KEY
done

[[ ! -d "~/.ssh" ]] && mkdir -p "~/.ssh" && chmod 700 ~/.ssh
echo $key >> ~/.ssh/authorized_keys
sed -i "s/PermitRootLogin.*/PermitRootLogin without-password/g" /etc/ssh/sshd_config

# Active
service ssh restart
