#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/gost.sh | bash

METHOD="-L=mwss://:443 -L=http2://:444"

VER="$(wget -qO- https://github.com/ginuerzh/gost/tags | grep -oE "/tag/v.*" | sed -n '1p' | sed 's/\".*//;s/^.*v//')"
VER=${VER:=2.7.2}
URL="https://github.com/ginuerzh/gost/releases/download/v${VER}/gost_${VER}_linux_amd64.tar.gz"

echo "Downloading gost_${VER} to /root/gost from $URL"
rm -rf /root/gost
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

systemctl enable gost.service && systemctl daemon-reload && systemctl restart gost.service && systemctl status gost -l
