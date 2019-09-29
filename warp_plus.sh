#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# Usage: warp.plus referrer  !!!!replace "6584a16f-eb84-4751-b137-8675e3fefc9e" to yours!!!!
## apt update && apt instal parallel -y
#### bash ./warp_plus.sh 100 20

# mission with threads, defaut: {20} {10}
mission="$1"
threads="$2"

echo; echo $(date) Mission ${mission:=20} GB. Starting with ${threads:=10} threads...

curldetails() {
	curl -X POST -sA "okhttp/3.12.1" -H 'content-type: application/json' --data "{\"key\": \"$(tr -dc '=_+/A-Za-z0-9' </dev/urandom | head -c 43)=\",\"referrer\": \"$1\",\"warp_enabled\": false,\"tos\": \"$(date -u +%FT%T.$(shuf -i 123-987 -n 1)Z)\",\"type\": \"Android\",\"locale\": \"en_US\"}"  "https://api.cloudflareclient.com/v0a745/reg" >/dev/null
}

export -f curldetails

seq ${mission} | parallel -j${threads} --bar curldetails "6584a16f-eb84-4751-b137-8675e3fefc9e"

echo $(date) Mission Accomplished Thanks!
