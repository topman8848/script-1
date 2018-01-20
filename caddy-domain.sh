#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/caddy-domain.sh | bash

# Make sure only root can run this script
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

# Set domain
read -p "Please input your domain name for vps:" domain </dev/tty
read -p "Please input reverse proxy domain:" romain </dev/tty

# caddy install
curl https://getcaddy.com | bash -s personal http.filemanager

# Config Caddyfile
cat > /root/Caddyfile<<-EOF
https://${domain} {
 gzip
 tls mixool0204@gmail.com
 proxy / https://${romain}
}
EOF

# start caddy
killall -9 $(ps -ef|grep "apache2"|grep -v "grep"|awk '{print $2}') && apt-get remove --purge apache2 -y
nohup caddy -conf /root/Caddyfile &

#Informations
echo "All done!"
