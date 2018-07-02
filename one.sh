#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/debian-9/one.sh | bash

# Color
red='\033[0;31m'
green='\033[0;32m'
plain='\033[0m'

# Make sure only root can run this script
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

#BBR
modprobe tcp_bbr
echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
sysctl -p

# shadowsocks-libev and simple-obfs and haveged install 
echo "install shadowsocks-libev from jessie-backports-sloppy"
sh -c 'printf "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backports.list'
apt update
apt -t stretch-backports install shadowsocks-libev simple-obfs haveged -y

# Config shadowsocks with encrypt_method chacha20-ietf-poly1305 and obfs-tls
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
    "method":"chacha20-ietf-poly1305",
    "reuse-port":true,
    "fast_open":true,
    "plugin":"obfs-server",
    "plugin_opts":"obfs=tls"
}
EOF

# start haveged and ss-server
systemctl enable haveged shadowsocks-libev && systemctl start haveged shadowsocks-libev

#Informations
if systemctl status shadowsocks-libev >/dev/null; then
    echo -e "Congratulations, shadowsocks-libev server install completed!"
    echo -e "Server IP        : \033[41;37m $(get_ip) \033[0m"
    echo -e "Server Port      : \033[41;37m ${shadowsocksport} \033[0m"
    echo -e "Password         : \033[41;37m ${shadowsockspwd} \033[0m"
    echo -e "Encryption Method: \033[41;37m chacha20-ietf-poly1305 \033[0m"
    echo -e "SS Config File   : \033[41;37m /etc/shadowsocks-libev/config.json \033[0m"
    echo  
    echo -e "Command          : \033[41;37m systemctl status/start/stop/restart shadowsocks-libev \033[0m"
else
    echo -e "shadowsocks-libev start failed."
    echo -e "To check         : \033[41;37m systemctl status shadowsocks-libev \033[0m"
fi

get_ip(){
    local IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipinfo.io/ip )
    [ ! -z ${IP} ] && echo ${IP} || echo
}

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
            echo -e "[${red}Error${plain}] Input error, please input a number between 1 and 65535"
        fi
    else
        echo -e "[${red}Error${plain}] Input error, please input a number between 1 and 65535"
    fi
    done
