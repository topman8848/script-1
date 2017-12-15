#!/bin/bash
apt update
apt install libmicrohttpd-dev libssl-dev build-essential libhwloc-dev git curl -y
curl -L http://www.cmake.org/files/v3.4/cmake-3.4.1.tar.gz | tar -xvzf - -C /tmp/
cd /tmp/cmake-3.4.1/ && ./configure && make && sudo make install && cd -
update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force
git clone https://github.com/fireice-uk/xmr-stak.git
mkdir xmr-stak/build
cd xmr-stak/build
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/xmr-stak-cpu
make install

