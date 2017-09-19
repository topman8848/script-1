#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/rinetd.sh | bash

export green='\033[0;32m'
export plain='\033[0m'

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

echo -e "${green}Clean up $NAME${plain}"
systemctl disable $NAME.service
killall -9 $NAME
rm -rf /root/$NAME  /root/$NAME.conf /etc/systemd/system/$NAME.service

echo "Download $NAME from $URL"
curl -L "${URL}" >/root/$NAME
chmod +x /root/$NAME

echo "Generate /root/$NAME.conf"
read -p "Input ports [1-65535] you want to speed up: " PORTS </dev/tty
read -p "Input ports [1-65535] you want to speed up: " -a PORT </dev/tty

for a in $PORTS
do          
cat <<EOF >> /root/$NAME.conf
0.0.0.0 $a 0.0.0.0 $a
EOF
done 

#TWO=( $(seq ${PORT[0]} ${PORT[1]}) $(seq ${PORT[1]} ${PORT[0]}) )
for b in "$(seq ${PORT[0]} ${PORT[1]}) $(seq ${PORT[1]} ${PORT[0]})"
do          
cat <<EOF >> /root/$NAME.conf
0.0.0.0 $b 0.0.0.0 $b
EOF
done 

sort -u -n -k 2 /root/$NAME.conf -o /root/$NAME.conf

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

echo "Enable $NAME Service"
systemctl enable $NAME.service

echo "Start $NAME Service"
systemctl start $NAME.service

if systemctl status $NAME >/dev/null; then
	echo "$NAME started."
	echo -e "${green}$PORTS${plain} speed up completed."
	echo -e "${green}vi /root/$NAME.conf${plain} as needed."
	echo -e "${green}killall -9 $NAME${plain} for restart."
else
	echo "$NAME start failed."
fi
