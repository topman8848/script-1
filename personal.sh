#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/personal.sh | bash

read -p "Input url: " MYURL </dev/tty

curl -k  $MYURL | grep -oE "ssr?\://.*" | awk '{print $1}' | awk -F\" '{print $1}' | awk -F\< '{print $1}' | awk -F\\ '{print $1}' | sort -u
