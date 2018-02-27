#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/personal.sh | bash

read -p "Input url: " myurl </dev/tty

curl -k  myurl -o 0.conf

grep -oE "ssr?\://.*" 0.conf >1.conf

awk '{print $1}' 1.conf >2.conf

awk -F\" '{print $1}' 2.conf >3.conf

awk -F\< '{print $1}' 3.conf  >4.conf

awk -F\\ '{print $1}' 4.conf  >5.conf

sort -u 5.conf -o >ok.conf

cat ok.conf
