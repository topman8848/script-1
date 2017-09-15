#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/get-rinetd.sh | bash

export RINET_URL="https://raw.githubusercontent.com/mixool/script/source/rinetd_bbr_powered"

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

echo "1. Download rinetd from $RINET_URL"
curl -L "${RINET_URL}" >/root/rinetd
chmod +x /root/rinetd

echo "2. Generate /root/rinetd.conf"
cat <<EOF > /root/rinetd.conf
# bindadress bindport connectaddress connectport
0.0.0.0 443 0.0.0.0 443
0.0.0.0 80 0.0.0.0 80
EOF

IFACE=$(ip -4 addr | awk '{if ($1 ~ /inet/ && $NF ~ /^[ve]/) {a=$NF}} END{print a}')
echo "3. Generate /etc/systemd/system/rinetd-bbr.service"
cat <<EOF > /etc/systemd/system/rinetd.service
[Unit]
Description=rinetd with bbr
Documentation=https://github.com/linhua55/lkl_study

[Service]
ExecStart=/root/rinetd -f -c /root/rinetd.conf raw ${IFACE}
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "4. Enable rinetd Service"
systemctl enable rinetd.service

echo "5. Start rinetd Service"
systemctl start rinetd.service

if systemctl status rinetd >/dev/null; then
	echo "rinetd started."
	echo "By default, it only proxy(speed up) port 80 and 443, vi /etc/rinetd-bbr.conf the port number as needed."
else
	echo "rinetd failed."
fi