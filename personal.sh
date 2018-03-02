#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/personal.sh | bash

read -p "Input url: " URL </dev/tty

curl -k  $URL | grep -oE "ssr?://[^x][a-zA-Z0-9]+" | sort -u
