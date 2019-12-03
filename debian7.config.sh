cat <<EOF > /etc/apt/sources.list
deb http://archive.debian.org/debian/ wheezy main
deb-src http://archive.debian.org/debian/ wheezy main
EOF

apt-get update

apt-get install debian-archive-keyring
apt-key update
apt-get clean && apt-get update
apt-get install wget curl vim -y
