#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/caddy-domain.sh | bash

# Informations
read -p "Please input your domain name for vps:" domain </dev/tty
read -p "Please input reverse proxy domain:" romain </dev/tty
read -p "Please input your user name:" user </dev/tty
read -p "Please input your password:" passwd </dev/tty

# caddy install
curl https://getcaddy.com | bash -s personal

# Config Caddyfile
cat > /etc/caddy/Caddyfile<<-EOF
${domain} {
 basicauth / ${user} ${passwd}
 proxy / ${romain}
}
EOF

echo "Generate /etc/systemd/system/caddy.service"

cat <<EOF > /etc/systemd/system/caddy.service
[Unit]
Description=Caddy HTTP/2 web server
Documentation=https://caddyserver.com/docs
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
ExecStart=/usr/local/bin/caddy -log stdout -agree=true -conf=/etc/caddy/Caddyfile
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "Enable caddy.service"
systemctl enable caddy.service

# start caddy
killall -9 apache2 nginx
systemctl start caddy.service

if systemctl status caddy >/dev/null; then
        echo "caddy.service started. config file: /etc/caddy/Caddyfile"
        echo -e "Restart: systemctl daemon-reload && systemctl restart caddy.service."
        echo -e "Your site: ${domain}"
else
        echo "caddy.service start failed."
fi
