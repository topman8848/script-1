#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/easystart.sh | bash

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

export green='\033[0;32m'
export plain='\033[0m'

read url
read name
read do

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