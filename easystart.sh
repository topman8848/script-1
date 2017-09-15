#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/easystart.sh | bash

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

export green='\033[0;32m'
export plain='\033[0m'

pre_install(){
    echo "Please input password for shadowsocks-python"
    read -p "(Default password: teddysun.com):" url
    [ -z "${url}" ] && url="teddysun.com"
    echo
    echo "---------------------------"
    echo "password = ${shadowsockspwd}"
    echo "---------------------------"
    echo
    # Set shadowsocks config port
    while true
    do
    echo "Please input port for shadowsocks-python [1-65535]"
    read -p "(Default port: 8989):" name
    [ -z "$name" ] && name="8989"

    # Set shadowsocks config stream ciphers
    while true
    do
    echo -e "Please select stream cipher for shadowsocks-python:"
    read -p "Which cipher you'd select(Default: ${ciphers[0]}):" do
    [ -z "$do" ] && do=1
}

echo "download $name from $url"
curl -L "${url}" >/root/$name
chmod +x /root/$name

echo "Generate /etc/systemd/system/$name.service"
cat <<EOF > /etc/systemd/system/$name.service
[Unit]
Description=$name

[Service]
ExecStart=/root/$name $do
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "4. Enable $name Service"
systemctl enable $name.service

echo "5. Start $name Service"
systemctl start $name.service

if systemctl status $name >/dev/null; then
	echo "$name started."
	echo -e "${green}vi /etc/systemd/system/$name.service${plain} as needed."
	echo -e "${green}killall -9 $name${plain} for restart."
else
	echo "$name start failed."
fi