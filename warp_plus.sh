#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# Usage: warp.plus referrer  !!!!replace "daf24432-88af-4d53-b2df-4b52c1fa4cd3" to yours!!!!
## apt update && apt instal parallel -y
#### bash ./warp_plus.sh 100 20

# mission with threads, defaut: {20} {10}
mission="$1" && threads="$2"

curldetails() {
	curl -X POST -sA "okhttp/3.12.1" -H 'content-type: application/json' --connect-timeout 3 --data "{\"key\": \"$(tr -dc '=_+/A-Za-z0-9' </dev/urandom | head -c 43)=\",\"referrer\": \"$1\",\"warp_enabled\": false,\"tos\": \"$(date -u +%FT%T.$(shuf -i 123-987 -n 1)Z)\",\"type\": \"Android\",\"locale\": \"en_US\"}"  "https://api.cloudflareclient.com/v0a745/reg" >/dev/null
}

export -f curldetails

seq ${mission:=20} | parallel -j${threads:=10} --eta curldetails "daf24432-88af-4d53-b2df-4b52c1fa4cd3"
