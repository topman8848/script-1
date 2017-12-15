#!/bin/bash
# Usage:
#   wget --no-check-certificate  https://raw.githubusercontent.com/mixool/script/master/xmr-cpu.sh && chmod +x xmr-cpu.sh && echo | ./xmr-cpu.sh

#Set export
export UP="us-backup.supportxmr.com:3333"
export WA="41j3DkPVeJkZvfq9q7Zf6DRB1rg5HmZy426GKs1wRdFpSMZLgSqVAFUjXqrT3anyZ22j7DEE74GkbVcQFyH2nNiC3hjFYhF"
export PW="dog"

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
cmake .. -DCUDA_ENABLE=OFF  -DOpenCL_ENABLE=OFF
make install

#My cpu.txt
cat <<EOF >> /root/xmr-stak/build/bin/cpu.txt
"cpu_threads_conf" :
[
    { "low_power_mode" : true, "no_prefetch" : true, "affine_to_cpu" : 0 },

],
EOF

#Run xmr-stak and cpulimit
cpulimit --exe xmr-stak --limit 60 -b
nohup /root/xmr-stak/build/bin/xmr-stak -o $UP -u $WA -p $PW &


