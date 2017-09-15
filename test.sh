#!/bin/bash
# Usage:
#   wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/master/easystart.sh
#   chmod +x easystart.sh
#   ./easystart.sh


if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

export green='\033[0;32m'
export plain='\033[0m'

read -p "Download url: " URL </dev/tty
read -p "Service name: " NAME </dev/tty
read -p "Start command: " DO </dev/tty

echo -e "${green}Clean up $NAME${plain}"
systemctl disable $NAME.service
killall -9 $NAME
rm -rf /root/$NAME /etc/systemd/system/$NAME.service

echo "Download $NAME from $URL"
wget --no-check-certificate $URL -O /root/$NAME
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
	echo "$NAME started."
	echo -e "${green}vi /etc/systemd/system/$NAME.service${plain} or run this script again as needed."
	echo -e "${green}killall -9 $NAME${plain} for restart."
else
	echo "$NAME start failed."
fi
