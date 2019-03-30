#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/gost.sh | bash

METHOD="-L=mwss://:443"

VER="$(wget -qO- https://github.com/ginuerzh/gost/tags | grep -oE "/ginuerzh/gost/releases/tag/v.*" | sed -n '1p' | sed 's/".*//' | sed 's/^.*v//')"
VER=${VER:=2.7.2}
URL="https://github.com/ginuerzh/gost/releases/download/v${VER}/gost_${VER}_linux_amd64.tar.gz"

echo -e "Clean up gost"
systemctl disable gost.service
killall -9 gost
rm -rf /root/gost

echo "Downloading gost_${VER} from $URL"
wget -O /root/gost_${VER}_linux_amd64.tar.gz $URL
tar -zxvf /root/gost_${VER}_linux_amd64.tar.gz && cd /root/gost_${VER}_linux_amd64 && mv gost /root/gost && cd
rm -rf /root/gost_${VER}_linux_amd64*
chmod +x /root/gost

echo "Generate /etc/systemd/system/gost.service"
cat <<EOF > /etc/systemd/system/gost.service
[Unit]
Description=gost
[Service]
ExecStart=/root/gost $METHOD
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF

echo "Starting gost service"
systemctl enable gost.service && systemctl daemon-reload && systemctl start gost.service

if systemctl status gost >/dev/null; then
	echo "gost started."
	echo -e "vi /etc/systemd/system/gost.service as needed."
	echo -e "systemctl daemon-reload && systemctl restart gost.service for restart."
else
	echo "gost start failed."
	systemctl status gost -l	
fi
