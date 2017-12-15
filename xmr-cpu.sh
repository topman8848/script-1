#!/bin/bash
# Usage:
#   wget --no-check-certificate  https://raw.githubusercontent.com/mixool/script/master/xmr-cpu.sh && chmod +x xmr-cpu.sh && echo | ./xmr-cpu.sh

#Compile xmr-stak for Ubuntu 14.04
apt-get update
apt-get install -y python-software-properties
add-apt-repository ppa:ubuntu-toolchain-r/test
apt update
apt install -y gcc-5 g++-5 make curl git cpulimit
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 1 --slave /usr/bin/g++ g++ /usr/bin/g++-5
curl -L http://www.cmake.org/files/v3.4/cmake-3.4.1.tar.gz | tar -xvzf - -C /tmp/
cd /tmp/cmake-3.4.1/ && ./configure && make && sudo make install && cd -
update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force
apt install -y libmicrohttpd-dev libssl-dev libhwloc-dev
git clone https://github.com/fireice-uk/xmr-stak.git
mkdir xmr-stak/build
cd xmr-stak/build
cmake ..
make install
