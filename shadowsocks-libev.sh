#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/debian-9/shadowsocks-libev.sh | bash

# only root can run this script
[[ $EUID -ne 0 ]] && echo "Error, This script must be run as root!" && exit 1

# set password
    read -p "Please input password for shadowsocks-libev:" shadowsockspwd </dev/tty
    echo
    echo "---------------------------"
    echo "password = ${shadowsockspwd}"
    echo "---------------------------"
    echo

# set port
    while true
    do
    echo -e "Please input port for shadowsocks-libev [1-65535]:"
    read -p "(Default port: 8443):" shadowsocksport </dev/tty
    [ -z "$shadowsocksport" ] && shadowsocksport="8443"
    expr ${shadowsocksport} + 1 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ ${shadowsocksport} -ge 1 ] && [ ${shadowsocksport} -le 65535 ]; then
            echo
            echo "---------------------------"
            echo "port = ${shadowsocksport}"
            echo "---------------------------"
            echo
            break
        else
            echo "Input error, please input a number between 1 and 65535"
        fi
    else
        echo "Input error, please input a number between 1 and 65535"
    fi
    done
    
# install shadowsocks-libev from stretch-backports
sh -c 'printf "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backports.list'
apt update
apt -t stretch-backports install shadowsocks-libev -y

# shadowsocks-libev config
cat >/etc/shadowsocks-libev/config.json<<-EOF
{
    "server":["::0", "0.0.0.0"],
    "mode":"tcp_and_udp",
    "server_port":${shadowsocksport},
    "local_port":1080,
    "password":"${shadowsockspwd}",
    "timeout":60,
    "method":"chacha20-ietf-poly1305"
}
EOF

# systemctl shadowsocks-libev informations
systemctl restart shadowsocks-libev && systemctl status shadowsocks-libev
