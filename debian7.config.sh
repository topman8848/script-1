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
wget https://github.com/ginuerzh/gost/releases/download/v2.8.1/gost_2.8.1_linux_386.tar.gz
tar -zxvf gost_2.8.1_linux_386.tar.gz
mv /root/gost_2.8.1_linux_386/gost /root/gost && chmod +x /root/gost
rm -rf /root/gost_2.8.1_linux_386  /root/gost_2.8.1_linux_386.tar.gz
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
