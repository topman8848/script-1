#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/debian-9/shadowsocks-libev.sh | bash

# Make sure only root can run this script
[[ $EUID -ne 0 ]] && echo "Error, This script must be run as root!" && exit 1

get_ipv6(){
    local ipv6=$(wget -qO- -t1 -T2 ipv6.icanhazip.com)
    if [ -z ${ipv6} ]; then
        return 1
    else
        return 0
    fi
}

# Set password
	read -p "Please input password for shadowsocks-libev:" shadowsockspwd </dev/tty
    echo
    echo "---------------------------"
    echo "password = ${shadowsockspwd}"
    echo "---------------------------"
    echo

# Set port
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
            echo -e "Input error, please input a number between 1 and 65535"
        fi
    else
        echo -e "Input error, please input a number between 1 and 65535"
    fi
    done
    
# shadowsocks-libev and haveged install 
echo "install shadowsocks-libev from jessie-backports-sloppy"
sh -c 'printf "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backports.list'
apt update
apt -t stretch-backports install shadowsocks-libev haveged -y

# Config shadowsocks with encrypt_method chacha20-ietf
server_value="\"0.0.0.0\""
if get_ipv6; then
        server_value="[\"[::0]\",\"0.0.0.0\"]"
fi

if [ ! -d /etc/shadowsocks-libev ]; then
        mkdir -p /etc/shadowsocks-libev
fi

cat > /etc/shadowsocks-libev/config.json<<-EOF
{
    "server":${server_value},
    "server_port":${shadowsocksport},
    "password":"${shadowsockspwd}",
    "method":"chacha20-ietf"
}
EOF

# start haveged and ss-server
systemctl enable haveged shadowsocks-libev && systemctl start haveged shadowsocks-libev

#Informations of shadowsocks-libev
systemctl status shadowsocks-libev
