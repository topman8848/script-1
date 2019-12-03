cat <<EOF > /etc/apt/sources.list
deb http://archive.debian.org/debian/ wheezy main
deb-src http://archive.debian.org/debian/ wheezy main
EOF

apt-get update
apt-get install debian-archive-keyring
apt-key update
apt-get install wget curl vim systemd-sysv -y 
apt-get clean


### Generate /etc/systemd/system/gost.service
cat <<EOF > /etc/systemd/system/gost.service
[Unit]
Description=gost
[Service]
ExecStart=/root/gost -L=ss2+ohttp://AEAD_AES_128_GCM:1234567@:80
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF

systemctl enable gost.service && systemctl restart gost.service && systemctl status gost.service


# SSSSHHHHHHHHHHHHHHKEY
read -p "Please input ssh port:" port </dev/tty
read -p "Please input the public key:" key </dev/tty


mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo $key >> ~/.ssh/authorized_keys


cp /etc/ssh/sshd_config /etc/ssh/sshd_config_bak
echo -e "Port ${port}" >> /etc/ssh/sshd_config
sed -i "s/PermitRootLogin.*/PermitRootLogin without-password/g" /etc/ssh/sshd_config

systemctl reload sshd.service
