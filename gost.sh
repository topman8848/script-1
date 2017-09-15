#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/gost.sh | bash

export URL="https://raw.githubusercontent.com/mixool/script/source/gost"
export NAME="gost"

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

echo "1. Download $NAME from $URL"
curl -L "${URL}" >/root/$NAME
chmod +x /root/$NAME

echo "2. Generate /etc/systemd/system/$NAME.service"
cat <<EOF > /etc/systemd/system/$NAME.service
[Unit]
Description=$NAME

[Service]
ExecStart=/root/$NAME -L=:443
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
	echo "vi /etc/systemd/system/$NAME.service as needed."
else
	echo "$NAME failed."
fi