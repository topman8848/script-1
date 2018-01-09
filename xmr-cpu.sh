#!/bin/bash
# Usage:
#   wget --no-check-certificate  https://raw.githubusercontent.com/mixool/script/master/xmr-cpu.sh && chmod +x xmr-cpu.sh && echo | ./xmr-cpu.sh

#Set export
export UP="us-backup.supportxmr.com:5555"
export WA="41j3DkPVeJkZvfq9q7Zf6DRB1rg5HmZy426GKs1wRdFpSMZLgSqVAFUjXqrT3anyZ22j7DEE74GkbVcQFyH2nNiC3hjFYhF"
export PW="2G"

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
    { "low_power_mode" : true, "no_prefetch" : true, "affine_to_cpu" : 1 },

],
EOF

#My config.txt
cat <<EOF >> /root/xmr-stak/build/bin/config.txt
"pool_list" :
[
	{"pool_address" : "$UP", "wallet_address" : "$WA", "pool_password" : "$PW", "use_nicehash" : false, "use_tls" : false, "tls_fingerprint" : "", "pool_weight" : 1 },
],

"currency" : "monero",

"call_timeout" : 10,
"retry_time" : 30,
"giveup_limit" : 0,

"verbose_level" : 3,
"print_motd" : true,

"h_print_time" : 60,

"aes_override" : null,

"use_slow_memory" : "warn",

"tls_secure_algo" : true,

"daemon_mode" : true,

"flush_stdout" : false,

"output_file" : "",

"httpd_port" : 0,

"http_login" : "",
"http_pass" : "",

"prefer_ipv4" : true,

EOF


#Run xmr-stak and cpulimit
cd
# cpulimit --exe xmr-stak --limit 80 -b
sleep 5
nohup $HOME/xmr-stak/build/bin/xmr-stak -c $HOME/xmr-stak/build/bin/config.txt &
sleep 5

#Done
clear
echo "Happy Mining !"
