#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/sslibev-kcptun.sh | bash

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

# Kcptun export 
export URL="https://raw.githubusercontent.com/mixool/script/source/server_linux_amd64"
export NAME="server_linux_amd64"

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
    read -p "(Default port: 443):" shadowsocksport </dev/tty
    [ -z "$shadowsocksport" ] && shadowsocksport="443"
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
    
# Set kcptun config port
while true
do
	echo -e "Please input port for kcptun [1-65535]:"
	read -p "(Default port: 8443):" kport </dev/tty
	[ -z "$kport" ] && kport="8443"
	expr ${kport} + 1 &>/dev/null
	if [ $? -eq 0 ]; then
        	if [ ${kport} -ge 1 ] && [ ${kport} -le 65535 ]; then
            		echo
            		echo "---------------------------"
            		echo "your kcptun port = ${kport}"
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

# Config shadowsocks
config_shadowsocks(){
    local server_value="\"0.0.0.0\""
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
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"${shadowsockspwd}",
    "timeout":600,
    "method":"${shadowsockscipher}"
}
EOF
}

# Shadowsocks-libev install
echo "install shadowsocks-libev from jessie-backports-sloppy"
sh -c 'printf "deb http://deb.debian.org/debian jessie-backports main\n" > /etc/apt/sources.list.d/jessie-backports.list'
sh -c 'printf "deb http://deb.debian.org/debian jessie-backports-sloppy main" >> /etc/apt/sources.list.d/jessie-backports.list'
apt update
apt -t jessie-backports-sloppy install shadowsocks-libev -y

#Kcpservice install
echo "Clean up $NAME"
systemctl disable $NAME.service
killall -9 $NAME
rm -rf /root/$NAME /etc/systemd/system/$NAME.service

echo "Download $NAME from $URL"
curl -L "${URL}" >/root/$NAME
chmod +x /root/$NAME

echo "Generate /etc/systemd/system/$NAME.service"

cat <<EOF > /etc/systemd/system/$NAME.service
[Unit]
Description=$NAME

[Service]
ExecStart=/root/$NAME -l :$kport -t 127.0.0.1:$shadowsocksport --mode fast
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "Enable $NAME Service"
systemctl enable $NAME.service

echo "Start $NAME Service"
systemctl start $NAME.service

clear

#Informations
if systemctl status shadowsocks-libev >/dev/null; then
    echo -e "Congratulations, Shadowsocks-libev server install completed!"
    echo -e "Your Server IP        : \033[41;37m $(get_ip) \033[0m"
    echo -e "Your Server Port      : \033[41;37m ${shadowsocksport} \033[0m"
    echo -e "Your Password         : \033[41;37m ${shadowsockspwd} \033[0m"
    echo -e "Your Encryption Method: \033[41;37m ${shadowsockscipher} \033[0m"
    echo  
    echo -e "SS-libev config       : \033[41;37m /etc/shadowsocks-libev/config.json \033[0m"
    echo -e "SS-libev command      : \033[41;37m systemctl start/stop/restart/status shadowsocks-libev \033[0m"
else
    echo "ss-server start failed."
fi

if systemctl status $NAME >/dev/null; then
	echo 
	echo -e "Congratulations, Kcptun server install completed!"
	echo -e "Your Server IP        : \033[41;37m $(get_ip) \033[0m"
	echo -e "Your Server Port      : \033[41;37m ${kport} \033[0m"
	echo -e "Speedup Port          : \033[41;37m ${shadowsocksport} \033[0m"
	echo -e "Change run mode       : \033[41;37m vi /etc/systemd/system/$NAME.service \033[0m"
	echo -e "Restart kcptun server : \033[41;37m killall -9 $NAME$ \033[0m"
else
	echo "$NAME start failed."
fi
