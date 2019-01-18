#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
# Usage:
# Used for https://github.com/shadowsocks/shadowsocks-manager
#   wget --no-check-certificate -O ssmgr_ui_cf.sh https://raw.githubusercontent.com/mixool/script/master/ssmgr_ui_cf.sh && chmod +x ssmgr_ui_cf.sh && ./ssmgr_ui_cf.sh 2>&1 | tee ssmgr_ui_cf.sh.log

# Make sure only root can run this script
[[ $EUID -ne 0 ]] && echo -e "This script must be run as root!" && exit 1

# Disable selinux
disable_selinux(){
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}


preinstall_conf(){
    # set admin maigun
    read -p "(Please enter your mailgun baseUrl: https://api.mailgun.net/v3/xx.xxx.xxx):" baseUrl
    read -p "(Please enter your maigun apiKey: xxxxxxxxxxxxxxx-xxxxxx-xxxxxxx):" apiKey
    
    # set domain and email for caddyfile
    echo
    read -p "Please input your domain name for vps:" domain
    read -p "Please input your email:" email
    echo
    echo "---------------------------"
    echo "domain = ${domain}"
    echo "email  = ${email}"
    echo "---------------------------"
    echo
    
    # set CLOUDFLARE_EMAIL and CLOUDFLARE_API_KEY
    echo
    read -p "Please input your CLOUDFLARE_EMAIL:" CLOUDFLARE_EMAIL
    read -p "Please input your CLOUDFLARE_API_KEY:" CLOUDFLARE_API_KEY
    echo
    echo "---------------------------"
    echo "CLOUDFLARE_EMAIL = ${CLOUDFLARE_EMAIL}"
    echo "CLOUDFLARE_API_KEY  = ${CLOUDFLARE_API_KEY}"
    echo "---------------------------"
    echo
}

create_ssmgr_conf(){
    mkdir /root/.ssmgr/
    cat > /root/.ssmgr/webgui.yml<<EOF
type: m
manager:
  address: 1.2.3.4:5
  password: 1.2.3.4:5
plugins:
  flowSaver:
    use: true
  user:
    use: true
  account:
    use: true
  macAccount:
    use: true
  group:
    use: true
  email:
    use: true
    type: 'mailgun'
    baseUrl: '${baseUrl}'
    apiKey: '${apiKey}'
  webgui:
    use: true
    host: '127.0.0.1'
    port: '8080'
    site: 'http://${domain}'		
db: 'webgui.sqlite'
redis:
  host: '127.0.0.1'
  password: ''
  db: 0
EOF
}

npm_install_ssmgr_pm2(){
	apt-get update && apt-get install curl -y
	curl -sL https://deb.nodesource.com/setup_8.x | bash -
	apt-get install -y nodejs
	npm i -g shadowsocks-manager --unsafe-perm
	npm i -g pm2
}

install_caddy(){
curl https://getcaddy.com | bash -s personal tls.dns.cloudflare
mkdir /etc/caddy

cat > /etc/caddy/Caddyfile<<-EOF
${domain} {
proxy / http://127.0.0.1:8080 {
	transparent
	}
gzip
tls {
  dns cloudflare
  }
}
EOF

cat <<EOF > /etc/systemd/system/caddy.service
[Unit]
Description=Caddy HTTP/2 web server
Documentation=https://caddyserver.com/docs
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service
[Service]
ExecStart=/usr/local/bin/caddy -log stdout -conf=/etc/caddy/Caddyfile -email=${email} -agree=true
Restart=always
User=root
Environment=CLOUDFLARE_EMAIL=${CLOUDFLARE_EMAIL}
Environment=CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
[Install]
WantedBy=multi-user.target
EOF

systemctl enable caddy && systemctl start caddy
}

install_redis-server(){
apt-get install redis-server -y
systemctl enable redis-server && systemctl start redis-server
}

install_ssmgr_ui_cf(){
    echo
    echo "+---------------------------------------------------------------+"
    echo "One-key for ssmgr_ui_cf"
    echo "+---------------------------------------------------------------+"
    echo
    preinstall_conf
    create_ssmgr_conf
    npm_install_ssmgr_pm2
    install_redis-server
    pm2 -f -x -n ssmgr-webgui start ssmgr -- -c /root/.ssmgr/webgui.yml
    pm2 startup && pm2 save
    install_caddy
}

disable_selinux
install_ssmgr_ui_cf
echo "All done! Enjoy yourself"
pm2 list
