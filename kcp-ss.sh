#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/kcp-ss.sh | bash

export green='\033[0;32m'
export plain='\033[0m'

export URL="https://raw.githubusercontent.com/mixool/script/source/server_linux_amd64"
export NAME="server_linux_amd64"
export DO="-l :11001 -t 127.0.0.1:11000"

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

echo "install shadowsocks-libev from jessie-backports-sloppy"
sh -c 'printf "deb http://deb.debian.org/debian jessie-backports main\n" > /etc/apt/sources.list.d/jessie-backports.list'
sh -c 'printf "deb http://deb.debian.org/debian jessie-backports-sloppy main" >> /etc/apt/sources.list.d/jessie-backports.list'
apt update
apt -t jessie-backports-sloppy install shadowsocks-libev -y

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
