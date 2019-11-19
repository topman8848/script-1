#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/debian-9/gsnova.sh | bash

METHOD="-cmd -client -listen :$(shuf -i 10000-65535 -n1) -remote wss://xyz.herokuapp.com -key 809240d3a021449f6e67aa73221d42df942a308"

URL="https://github.com/yinqiwen/gsnova/releases/download/latest/gsnova_linux_amd64-latest.tar.bz2"

echo "Downloading gsnova latest to /root/gsnova from $URL"
[[ ! -d "/root/gsnova" ]] && mkdir /root/gsnova
rm -rf /root/gsnova/*
wget -O /root/gsnova/gsnova_linux_amd64-latest.tar.bz2 $URL
apt install bzip2 -y
tar -jxf /root/gsnova/gsnova_linux_amd64-latest.tar.bz2 -C /root/gsnova
chmod +x /root/gsnova/gsnova

echo "Generate /etc/systemd/system/gsnova.service"
cat <<EOF > /etc/systemd/system/gsnova.service
[Unit]
Description=gsnova
[Service]
ExecStart=/root/gsnova/gsnova $METHOD
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF

systemctl enable gsnova.service && systemctl daemon-reload && systemctl restart gsnova.service && systemctl status gsnova -l
