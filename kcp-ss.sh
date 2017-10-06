#!/bin/bash
# Thanks to teddysun.com
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/kcp-ss.sh | bash

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
export green='\033[0;32m'
export plain='\033[0m'

# Kcptun server
export URL="https://raw.githubusercontent.com/mixool/script/source/server_linux_amd64"
export NAME="server_linux_amd64"
export DO="-l :11001 -t 127.0.0.1:11000"

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

# shadowsocks-libev install
echo "install shadowsocks-libev from jessie-backports-sloppy"
sh -c 'printf "deb http://deb.debian.org/debian jessie-backports main\n" > /etc/apt/sources.list.d/jessie-backports.list'
sh -c 'printf "deb http://deb.debian.org/debian jessie-backports-sloppy main" >> /etc/apt/sources.list.d/jessie-backports.list'
apt update
apt -t jessie-backports-sloppy install shadowsocks-libev -y

# Set shadowsocks-libev config password
    echo "Please input password for shadowsocks-libev:"
    read -p "(Default password: 123456):" shadowsockspwd
    [ -z "${shadowsockspwd}" ] && shadowsockspwd="123456"
    echo
    echo "---------------------------"
    echo "password = ${shadowsockspwd}"
    echo "---------------------------"
    echo

# Set shadowsocks-libev config port
    while true
    do
    echo -e "Please input port for shadowsocks-libev [1-65535]:"
    read -p "(Default port: 8989):" shadowsocksport
    [ -z "$shadowsocksport" ] && shadowsocksport="8989"
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
    read -p "Which cipher you'd select(Default: ${ciphers[0]}):" pick
    [ -z "$pick" ] && pick=1
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

# Kcptun startup
echo -e "${green}Clean up $NAME${plain}"
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
ExecStart=/root/$NAME $DO
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "Enable $NAME Service"
systemctl enable $NAME.service

echo "Start $NAME Service"
systemctl start $NAME.service

if systemctl status $NAME >/dev/null; then
	echo "shadowsocks-libev started:"
	echo -e "config: ${green}vi /etc/shadowsocks-libev/config.json${plain}"
	echo -e "command: ${green}systemctl start/stop/restart/status shadowsocks-libev${plain}"
	echo "$NAME started:"
	echo -e "${green}vi /etc/systemd/system/$NAME.service${plain} as needed."
	echo -e "${green}killall -9 $NAME${plain} for restart."
else
	echo "$NAME start failed."
fi
