#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/caddy-domain.sh | bash

# Informations
read -p "Please input your domain name for vps:" domain </dev/tty
read -p "Please input reverse proxy domain:" romain </dev/tty
read -p "Please input your e-mail:" mail </dev/tty
read -p "Please input your user name:" user </dev/tty
read -p "Please input your password:" passwd </dev/tty

# caddy install
curl https://getcaddy.com | bash -s personal http.filemanager

# Config Caddyfile
cat > /root/Caddyfile<<-EOF
https://${domain} {
 gzip
 tls ${mail}
 basicauth / ${user} ${passwd}
 proxy / https://${romain}
}
EOF

# start caddy
killall -9 apache2 nginx
nohup caddy -conf /root/Caddyfile >/dev/null 2>&1 &

#Informations
sleep 5
echo -e "Your site: https://${domain}"
