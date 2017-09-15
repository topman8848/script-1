#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/rinetd.sh | bash

export URL="https://raw.githubusercontent.com/mixool/script/source/rinetd_bbr_powered"
export NAME="rinetd"

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

for CMD in curl iptables grep cut xargs systemctl ip awk
do
	if ! type -p ${CMD}; then
		echo -e "\e[1;31mtool ${CMD} is not installed, abort.\e[0m"
		exit 1
	fi
done

echo "Update"
apt-get update
clear

echo "Download $NAME from $URL"
curl -L "${URL}" >/root/$NAME
chmod +x /root/$NAME

echo "Generate /root/$NAME.conf"
cat <<EOF > /root/$NAME.conf
# bindadress bindport connectaddress connectport
0.0.0.0 443 0.0.0.0 443
0.0.0.0 80 0.0.0.0 80
EOF

IFACE=$(ip -4 addr | awk '{if ($1 ~ /inet/ && $NF ~ /^[ve]/) {a=$NF}} END{print a}')

echo "Generate /etc/systemd/system/$NAME.service"

cat <<EOF > /etc/systemd/system/$NAME.service
[Unit]
Description=$NAME

[Service]
ExecStart=/root/$NAME -f -c /root/$NAME.conf raw ${IFACE}
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "4. Enable $NAME Service"
systemctl enable $NAME.service

echo "5. Start $NAME Service"
systemctl start $NAME.service

if systemctl status $NAME >/dev/null; then
	echo "$NAME started."
	echo "By default, it only speed up port 80 and 443, vi /etc/$NAME.conf as needed."
else
	echo "$NAME failed."
fi