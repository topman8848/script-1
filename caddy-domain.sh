#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/caddy-domain.sh | bash

# Set domain and e-mail
read -p "Please input your domain name for vps:" domain </dev/tty
read -p "Please input reverse proxy domain:" romain </dev/tty
read -p "Please input your e-mail:" mail </dev/tty

# caddy install
curl https://getcaddy.com | bash -s personal http.filemanager

# Config Caddyfile
cat > /root/Caddyfile<<-EOF
https://${domain} {
 gzip
 tls ${mail}
 proxy / https://${romain}
}
EOF

# start caddy
killall -9 $(ps -ef|grep "apache2"|grep -v "grep"|awk '{print $2}') && apt-get remove --purge apache2 -y
nohup caddy -conf /root/Caddyfile &

#Informations
echo "All done!"
