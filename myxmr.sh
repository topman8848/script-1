#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/myxmr.sh | bash
apt-get install -y python-software-properties 
add-apt-repository ppa:ubuntu-toolchain-r/test
apt update
apt install -y gcc-5 g++-5 make curl git cpulimit
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 1 --slave /usr/bin/g++ g++ /usr/bin/g++-5
curl -L http://www.cmake.org/files/v3.4/cmake-3.4.1.tar.gz | tar -xvzf - -C /tmp/
cd /tmp/cmake-3.4.1/ && ./configure && make && sudo make install && cd -
update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force
apt install -y libmicrohttpd-dev libssl-dev libhwloc-dev
git clone https://github.com/fireice-uk/xmr-stak-cpu xmr-stak
cd xmr-stak
cmake .
make install
rm /root/xmr-stak/bin/config.txt
wget https://raw.githubusercontent.com/mixool/script/source/config.txt -O /root/xmr-stak/bin/config.txt

sysctl -w vm.nr_hugepages=128

echo "* soft memlock 262144" >> /etc/security/limits.conf
echo "* hard memlock 262144" >> /etc/security/limits.conf

reboot
