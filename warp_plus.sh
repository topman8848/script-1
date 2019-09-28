#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# Usage: warp.plus referrer ### !!!replace "23320584-5625-4f47-89a8-c760a29b0a1e " to yours!!!
#### bash ./examples.sh 10 100

# thread && loopss && defaut is 20 && 5
export thread="$1"
export loopss="$2"

echo; echo $(date) Mission $((${thread:=20}*${loopss:=5})) GB. Starting with ${thread} threads and ${loopss} loops...

curldetails() {
	for thread in $(seq ${loopss}); do
		curl -X POST -sA "okhttp/3.12.1" -H 'content-type: application/json' --data "{\"key\": \"$(tr -dc '=_+/A-Za-z0-9' </dev/urandom | head -c 43)=\",\"referrer\": \"23320584-5625-4f47-89a8-c760a29b0a1e\",\"warp_enabled\": false,\"tos\": \"$(date -u +%FT%T.$(shuf -i 123-987 -n 1)Z)\",\"type\": \"Android\",\"locale\": \"en_US\"}"  "https://api.cloudflareclient.com/v0a745/reg" >/dev/null
	done
}

export -f curldetails

seq ${thread} | parallel -j0 curldetails

echo $(date) Mission Accomplished Thanks!
