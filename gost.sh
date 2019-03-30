#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/gost.sh | bash

METHOD="-L=mwss://:443"

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

VER="$(wget -qO- https://github.com/ginuerzh/gost/tags | grep -oE "/ginuerzh/gost/releases/tag/v.*" | sed -n '1p' | sed 's/".*//' | sed 's/^.*v//')"
VER=${VER:=2.7.2}
URL="https://github.com/ginuerzh/gost/releases/download/v${VER}/gost_${VER}_linux_amd64.tar.gz"

echo "Download gost from $URL"
wget -O /root/gost_${VER}_linux_amd64.tar.gz $URL
tar -zxvf /root/gost_${VER}_linux_amd64.tar.gz && cd /root/gost_${VER}_linux_amd64 && mv gost /root/gost && cd
rm -rf /root/gost_${VER}_linux_amd64*
chmod +x /root/gost


export green='\033[0;32m'
export plain='\033[0m'
echo -e "${green}Clean up gost${plain}"
systemctl disable gost.service
killall -9 gost
rm -rf /root/gost

echo "Generate /etc/systemd/system/gost.service"
cat <<EOF > /etc/systemd/system/gost.service
[Unit]
Description=gost
[Service]
ExecStart=/root/gost $DO
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF

echo "Enable gost service"
systemctl enable gost.service && systemctl start gost.service

if systemctl status gost >/dev/null; then
	echo "gost started."
	echo -e "${green}vi /etc/systemd/system/gost.service${plain} as needed."
	echo -e "${green}systemctl daemon-reload && systemctl restart gost.service${plain} for restart."
else
	echo "gost start failed."
	systemctl status gost -l	
fi
