#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/goproxy-vps.sh | bash

#!/bin/bash

set -e

linkpath=$(ls -l "$0" 2>/dev/null | sed "s/.*->\s*//")
cd "$(dirname "$0")" && test -f "$linkpath" && cd "$(dirname "$linkpath")" || true

if [ "$(/bin/ls -ld promvps* 2>/dev/null | grep -c '^-')" = "0" ]; then
	mkdir -p promvps
	cd promvps
fi

FILENAME_PREFIX=
case $(uname -s)/$(uname -m) in
	Linux/x86_64 )
		FILENAME_PREFIX=promvps_linux_amd64
		;;
	Linux/i686|Linux/i386 )
		FILENAME_PREFIX=promvps_linux_386
		;;
	Linux/aarch64|Linux/arm64 )
		FILENAME_PREFIX=promvps_linux_arm64
		;;
	Linux/arm* )
		FILENAME_PREFIX=promvps_linux_arm
		if grep -q ld-linux-armhf.so ./promvps 2>/dev/null; then
			FILENAME_PREFIX=promvps_linux_arm_cgo
		fi
		;;
	Linux/mips64el )
		FILENAME_PREFIX=promvps_linux_mips64le
		;;
	Linux/mips64 )
		FILENAME_PREFIX=promvps_linux_mips64
		;;
	Linux/mipsel )
		FILENAME_PREFIX=promvps_linux_mipsle
		;;
	Linux/mips )
		FILENAME_PREFIX=promvps_linux_mips
		;;
	FreeBSD/x86_64 )
		FILENAME_PREFIX=promvps_freebsd_amd64
		;;
	FreeBSD/i686|FreeBSD/i386 )
		FILENAME_PREFIX=promvps_freebsd_386
		;;
	Darwin/x86_64 )
		FILENAME_PREFIX=promvps_macos_amd64
		;;
	Darwin/i686|Darwin/i386 )
		FILENAME_PREFIX=promvps_macos_386
		;;
	* )
		echo "Unsupported platform: $(uname -a)"
		exit 1
		;;
esac

LOCALVERSION=$(./promvps -version 2>/dev/null || :)
echo "0. Local Prom VPS version ${LOCALVERSION}"

echo "1. Checking Prom VPS Version"
curl -kL https://github.com/phuslu/promci/releases >promci.txt
RELEASETAG=$(cat promci.txt | grep -m1 -oE 'promci/releases/tag/[0-9A-Za-z]+' | awk -F/ '{print $NF}')
FILENAME=$(cat promci.txt | grep -oE "${FILENAME_PREFIX}-r[0-9]+.[0-9a-z\.]+" | head -1)
REMOTEVERSION=$(echo ${FILENAME} | awk -F'.' '{print $1}' | awk -F'-' '{print $2}')
rm -rf promci.txt
if [ -z "${REMOTEVERSION}" ]; then
	echo "Cannot detect ${FILENAME_PREFIX} version"
	exit 1
fi

if [[ ${LOCALVERSION#r*} -ge ${REMOTEVERSION#r*} ]]; then
	echo "Your Prom already update to latest"
	exit 1
fi

echo "2. Downloading ${FILENAME}"
curl -kL https://github.com/phuslu/promci/releases/download/${RELEASETAG}/${FILENAME} >${FILENAME}.tmp
mv -f ${FILENAME}.tmp ${FILENAME}

echo "3. Extracting ${FILENAME}"
rm -rf ${FILENAME%.*}
case ${FILENAME##*.} in
	xz )
		xz -d ${FILENAME}
		;;
	bz2 )
		bzip2 -d ${FILENAME}
		;;
	gz )
		gzip -d ${FILENAME}
		;;
	* )
		echo "Unsupported archive format: ${FILENAME}"
		exit 1
esac

tar -xvpf ${FILENAME%.*} --strip-components $(tar -tf ${FILENAME%.*} | head -1 | grep -c '/')
rm -f ${FILENAME%.*}

if [ ! -f promvps.user.toml ]; then
        echo "4. Configure promvps"

        read_p=$(test -n "$BASH_VERSION" && echo 'read -ep' || echo 'read -p')
        $read_p "Please input your domain: " server_name </dev/tty
        $read_p "Enable PAM Auth for promvps? [y/N]:" pam_auth </dev/tty

        cat <<EOF >promvps.toml
[default]
log_level = 2
reject_nil_sni = true

[[http2]]
listen = ":443"
server_name = ["${server_name}"]
disable_legacy_ssl = true
proxy_fallback = "http://127.0.0.1:80"
EOF
	if [ "${pam_auth}" = "y" ]; then
		echo 'proxy_auth_method = "pam"' >>promvps.toml
	else
		echo '#proxy_auth_method = "pam"' >>promvps.toml
	fi

fi

echo "Done"
echo

SUDO=$(test $(id -u) = 0 -a -z "${SUDO_USER}" || echo sudo)
RESTART=$(pgrep promvps >/dev/null && echo restart || echo start)
echo "Please run \"${SUDO} $(pwd)/promvps.sh ${RESTART}\""
