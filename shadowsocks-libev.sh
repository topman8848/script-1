#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/shadowsocks-libev.sh | bash

# Stream Ciphers
ciphers=(
aes-256-gcm
aes-192-gcm
aes-128-gcm
aes-256-ctr
aes-192-ctr
aes-128-ctr
aes-256-cfb
aes-192-cfb
aes-128-cfb
camellia-128-cfb
camellia-192-cfb
camellia-256-cfb
xchacha20-ietf-poly1305
chacha20-ietf-poly1305
chacha20-ietf
chacha20
salsa20
rc4-md5
)

# Color
red='\033[0;31m'
green='\033[0;32m'
plain='\033[0m'

# Make sure only root can run this script
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

# Disable selinux
disable_selinux(){
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}

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

# Set shadowsocks-libev config password
	read -p "Please input password for shadowsocks-libev:" shadowsockspwd </dev/tty
    echo
    echo "---------------------------"
    echo "password = ${shadowsockspwd}"
    echo "---------------------------"
    echo

# Set shadowsocks-libev config port
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

# Set obfs-server port
	while true
	do
    echo -e "Please input port for obfs-server [1-65535]:"
    read -p "(Default port: 443):" obfsport </dev/tty
    [ -z "$obfsport" ] && obfsport="443"
    expr ${obfsport} + 1 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ ${obfsport} -ge 1 ] && [ ${obfsport} -le 65535 ]; then
            echo
            echo "---------------------------"
            echo "port = ${obfsport}"
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

    # Set shadowsocks config stream ciphers
    while true
    do
    echo -e "Please select stream cipher for shadowsocks-libev:"
    for ((i=1;i<=${#ciphers[@]};i++ )); do
        hint="${ciphers[$i-1]}"
        echo -e "${green}${i}${plain}) ${hint}"
    done
    read -p "Which cipher you'd select(Default: ${ciphers[13]}):" pick </dev/tty
    [ -z "$pick" ] && pick=14
    expr ${pick} + 1 &>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "[${red}Error${plain}] Input error, please input a number"
        continue
    fi
    if [[ "$pick" -lt 1 || "$pick" -gt ${#ciphers[@]} ]]; then
        echo -e "[${red}Error${plain}] Input error, please input a number between 1 and ${#ciphers[@]}"
        continue
    fi
    shadowsockscipher=${ciphers[$pick-1]}
    echo
    echo "---------------------------"
    echo "cipher = ${shadowsockscipher}"
    echo "---------------------------"
    echo
    break
    done

# shadowsocks-libev and simple-obfs install
echo "install shadowsocks-libev from jessie-backports-sloppy"
sh -c 'printf "deb http://deb.debian.org/debian jessie-backports main\n" > /etc/apt/sources.list.d/jessie-backports.list'
sh -c 'printf "deb http://deb.debian.org/debian jessie-backports-sloppy main" >> /etc/apt/sources.list.d/jessie-backports.list'
apt update
apt -t jessie-backports-sloppy install shadowsocks-libev simple-obfs -y

# Config shadowsocks
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
    "method":"${shadowsockscipher}"
}
EOF

# start ss-server
systemctl enable shadowsocks-libev && systemctl start shadowsocks-libev && systemctl restart shadowsocks-libev

#start obfs-server
setcap cap_net_bind_service+ep /usr/bin/obfs-server
cat <<EOF > /etc/systemd/system/obfs-server.service
[Unit]
Description=obfs-server

[Service]
ExecStart=/usr/bin/obfs-server -s 0.0.0.0 -p ${obfsport} -r 127.0.0.1:${shadowsocksport} --obfs tls
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable obfs-server.service && systemctl start obfs-server.service && systemctl restart obfs-server.service

#Monitor
rm -rf /opt/shadowsocks-crond.sh
wget --no-check-certificate -O /opt/shadowsocks-crond.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-crond.sh
chmod 755 /opt/shadowsocks-crond.sh
/opt/shadowsocks-crond.sh
(crontab -l ; echo "0 */2 * * * /opt/shadowsocks-crond.sh") | crontab -

#Informations
if systemctl status shadowsocks-libev >/dev/null; then
    echo -e "Congratulations, shadowsocks-libev server install completed!"
    echo -e "Server IP        : \033[41;37m $(get_ip) \033[0m"
    echo -e "Server Port      : \033[41;37m ${shadowsocksport} \033[0m"
    echo -e "Password         : \033[41;37m ${shadowsockspwd} \033[0m"
    echo -e "Encryption Method: \033[41;37m ${shadowsockscipher} \033[0m"
    echo -e "SS Config File   : \033[41;37m /etc/shadowsocks-libev/config.json \033[0m"
    echo  
    echo -e "Monitor logs     : \033[41;37m /var/log/shadowsocks-crond.log \033[0m"
    echo -e "Crontab Check    : \033[41;37m crontab -e \033[0m"
    echo
    echo -e "Simple-Obfs      : \033[41;37m TLS \033[0m"
    echo -e "Config File      : \033[41;37m /etc/systemd/system/obfs-server \033[0m"
    echo
    echo -e "Command          : \033[41;37m systemctl start/stop/restart/status shadowsocks-libev/obfs-server \033[0m"
else
    echo "shadowsocks-libev start failed."
    echo "https://github.com/mixool/script/blob/master/shadowsocks-libev.sh"
fi
