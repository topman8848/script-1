#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
# Usage:
# Used for https://github.com/shadowsocks/shadowsocks-manager
#   wget --no-check-certificate -O ssmgr_onekey.sh https://raw.githubusercontent.com/mixool/script/master/ssmgr_onekey.sh && chmod +x ssmgr_onekey.sh && ./ssmgr_onekey.sh 2>&1 | tee ssmgr_onekey.sh.log

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
    # set port for shadowsocks-libev
    sleep 1
    while :
    do
        echo
        echo "Please enter port for shadowsocks-libev:"
        read -p "(Default prot: 4000):" ss_libev_port
        [ -z "${ss_libev_port}" ] && ss_libev_port="4000"
        if ! echo ${ss_libev_port} |grep -q '^[0-9]\+$'; then
            echo
            echo -e "You are not enter numbers.,please try again."
        else
            break
        fi
    done
    # set port for shadowsocks-manager
    while :;do
        echo
        echo "Please enter port for shadowsocks-manager:"
        read -p "(Default prot: 4001):" ssmgr_port 
        [ -z "${ssmgr_port}" ] && ssmgr_port="4001"
        if ! echo ${ssmgr_port} |grep -q '^[0-9]\+$'; then
            echo
            echo -e "You are not enter numbers.,please try again."
        elif [ ${ssmgr_port} -eq ${ss_libev_port} ];then
            echo
            echo -e "This port is already in use,please try again."
        else
            break
        fi
    done

    # set passwd for shadowsocks-manager
    echo
    read -p "Please enter passwd for shadowsocks-manager:" ssmgr_passwd
	echo
    echo "---------------------------"
    echo "password = ${ssmgr_passwd}"
    echo "---------------------------"
    echo

    # set user port range
    while :; do
        echo
        echo "Please enter the port ranges use for user:"
        read -p "(Default prot: 50000-60000):" port_ranges
        [ -z "${port_ranges}" ] && port_ranges=50000-60000
        if ! echo ${port_ranges} |grep -q '^[0-9]\+\-[0-9]\+$'; then
            echo
            echo -e "You are not enter numbers.,please try again."
            continue
        fi
        start_port=`echo $port_ranges |awk -F '-' '{print $1}'`
        end_port=`echo $port_ranges |awk -F '-' '{print $2}'`
        if [ ${start_port} -ge 1 ] && [ ${end_port} -le 65535 ] ; then
            break
        else
            echo
            echo -e "[${red}Error!${plain}] Please enter a correct number [1-65535]"
        fi
    done

    # choose encryption method for shadowsocks-libev
    while true
    do
        echo
        echo -e "Please select stream encryptions for shadowsocks-libev:"
        for ((i=1;i<=${#encryptions[@]};i++ )); do
            hint="${encryptions[$i-1]}"
            echo -e "${hint}"
        done
        read -p "Which encryptions you'd select(Default: ${encryptions[0]}):" pick
        [ -z "$pick" ] && pick=1
        expr ${pick} + 1 &>/dev/null
        if [ $? -ne 0 ]; then
            echo
            echo -e "[${red}Error!${plain}] Please enter a number."
            continue
        fi
        if [[ "$pick" -lt 1 || "$pick" -gt ${#encryptions[@]} ]]; then
            echo
            echo -e "Please enter a number between 1 and ${#encryptions[@]}"
            continue
        fi
        ss_libev_encry=${encryptions[$pick-1]}
        echo
        echo "encryptions = ${ss_libev_encry}"
        break
    done

    # set admin maigun
    if [ "${ss_run}" == "webgui" ];then
		echo
        echo "Please enter your mailgun baseUrl:"
        read -p "(For example: https://api.mailgun.net/v3/mg.xxx.xxx):" baseUrl
		echo "Please enter your maigun apiKey:"
        read -p "(For example: bf9048325495ef2c37f9a1248c3359ce-c9270c97-e8f3178e):" apiKey
    fi
}

# Stream Ciphers
encryptions=(
aes-256-gcm
aes-192-gcm
aes-128-gcm
aes-256-ctr
aes-192-ctr
aes-128-ctr
aes-256-cfb
aes-192-cfb
aes-128-cfb
camellia-128-cfb
camellia-192-cfb
camellia-256-cfb
chacha20-ietf-poly1305
chacha20-ietf
chacha20
rc4-md5
)

get_ip(){
    local IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipinfo.io/ip )
    [ ! -z ${IP} ] && echo ${IP} || echo
}

create_file_conf(){
    # shadowsocks-manager configuration
    cat > /root/.ssmgr/ss.yml <<EOF
type: s

shadowsocks:
    address: 127.0.0.1:${ss_libev_port}
manager:
    address: 0.0.0.0:${ssmgr_port}
    password: '${ssmgr_passwd}'
db: 'ss.sqlite'
EOF

    if [ "${ss_run}" == "webgui" ];then
        cat > /root/.ssmgr/webgui.yml<<EOF
type: m

manager:
  address: $(get_ip):${ssmgr_port}
  password: '${ssmgr_passwd}'
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
    host: '0.0.0.0'
    port: '80'
    site: 'http://$(get_ip)'
		
db: 'webgui.sqlite'
EOF
    fi
}

print_conf(){
    echo
    echo "+---------------------------------------------------------------+"
    echo
    echo -e "        Your ss-libev port:    ${ss_libev_port}"
    echo -e "        Your ss-mgr port:      ${ssmgr_port}"
    echo -e "        Your ss-mgr passwd:    ${ssmgr_passwd}"
    echo -e "        Your port ranges:      ${port_ranges}"
    echo -e "        Your ss-libev-encry:   ${ss_libev_encry}"
    if [ "${ss_run}" == "webgui" ];then
    echo -e "        Your mailgun baseUrl:  ${baseUrl}"
    echo -e "        Your maigun apiKey:    ${apiKey}"
    fi
    echo
    echo "+---------------------------------------------------------------+"
}

install_ssmgr(){
    echo "install shadowsocks-manager from npm"
	sleep 3
	curl -sL https://deb.nodesource.com/setup_8.x | bash -
	apt-get install -y nodejs
	npm i -g shadowsocks-manager --unsafe-perm
}

install_pm2(){
    echo "install pm2 from npm"
    sleep 3
    npm i -g pm2
}

install_shadowsocks_libev(){
	echo "install shadowsocks-libev from jessie-backports-sloppy"
	sleep 3
	sh -c 'printf "deb http://deb.debian.org/debian jessie-backports main\n" > /etc/apt/sources.list.d/jessie-backports.list'
	sh -c 'printf "deb http://deb.debian.org/debian jessie-backports-sloppy main" >> /etc/apt/sources.list.d/jessie-backports.list'
	apt update
	apt -t jessie-backports-sloppy install shadowsocks-libev -y
}

install_ssmgr_onekey(){
    echo
    echo "+---------------------------------------------------------------+"
    echo "One-key for ssmgr"
    echo "+---------------------------------------------------------------+"
    echo
    echo "webgui or only ss?"
    read -p "(choose from webgui or ss,default:ss):" ss_run
    [ -z ${ss_run} ] && ss_run="ss"
    ss_run=$(echo ${ss_run} |tr [A-Z] [a-z])
	  disable_selinux
	  preinstall_conf
	  create_file_conf
	  install_ssmgr
	  install_pm2
	  install_shadowsocks_libev
    sleep 3
    while :;
    do
        if [ "${ss_run}" == "webgui" ] ;then
			pm2 start ss-manager --name=ssmanager -- -m ${ss_libev_encry} -u --manager-address 127.0.0.1:${ss_libev_port}
			pm2 --name ssmgr-ss -f start ssmgr -x -- -c ss.yml 
			pm2 --name ssmgr-webgui -f start ssmgr -x -- -c webgui.yml
			pm2 save && pm2 startup
            break
        elif [ "${ss_run}" == "ss" ] ;then
			pm2 start ss-manager --name=ssmanager -- -m ${ss_libev_encry} -u --manager-address 127.0.0.1:${ss_libev_port}
            pm2 --name ssmgr-ss -f start ssmgr -x -- -c ss.yml 
			pm2 save && pm2 startup
            break
        else
            echo
            echo "Please enter webgui or ss!"
        fi
    done
}

install_ssmgr_onekey
print_conf
echo "Command: pm2 list"
