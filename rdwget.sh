#!/bin/bash
# Usage:
#  bash <(curl -s https://raw.githubusercontent.com/mixool/script/master/rdwget.sh) 512
#  wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/master/rdwget.sh && chmod +x rdwget.sh && ./rdwget.sh

# Set MBlimit
MBlimit=1024
while [[ $# > 0 ]];do
	if grep '^[1-9][0-9]*$' <<< "$1" >/dev/null;then
		MBlimit="$1"
	fi
		shift
done

# User-Agent
UA="Mozilla/5.0 (Linux; Android 9; Nokia X6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Mobile Safari/537.36"

#
limit=$(awk 'BEGIN{printf "%.f\n",('$MBlimit'*1024*1024)}')
Limit=$limit

echo $(date) Mission $MBlimit MB ...
printf "%-20s %-20s %-20s\n" "File(MB)" Speed  "Total(MB)"

# url && siz
url="$(curl -sA "$UA" "https://go.10086.cn/rd/go/dh/navComp.do?pageType=application&versionType=touch&logType=into" | grep -oE "https[^'>]*" | grep -E "awstatsNav.do" | grep -E "rd\.go\.10086\.cn/go/apk" | tail -1 | grep -oE "linkUrl=[^&]*" | awk -F"[=]" '{print $NF}')"
siz=$(wget --spider -U "$UA"  -T 3 -t 3 $url -SO- /dev/null 2>&1 | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")

#
for((i = 1; i >= 1; i++))
	do
		[ "$url" == "" -o "$siz" == "" ] && break
		[[ $((limit-siz)) -lt 0 ]] && break
		
		s=$(wget -U "$UA" -T 1 -t 3 -SO- "$url" 2>&1 >/dev/null | grep -E "written to stdout" | awk -F"[written]" '{print $1}' | awk -F"[\(\)]" '{print $((NF-1))}')
		[[ $s == "" ]] && continue
		limit=$[$limit-$siz]
		printf "%-20s %-20s %-20s\n" $(awk 'BEGIN{printf "%.1f\n",('$siz'/1024/1024)}') "$s" $(awk 'BEGIN{printf "%.1f\n",(('$Limit'-'$limit')/1024/1024)}')
done

FMB=$(awk 'BEGIN{printf "%.2f\n",(('$Limit'-'$limit')/1024/1024)}')
FGB=$(awk 'BEGIN{printf "%.3f\n",(('$Limit'-'$limit')/1024/1024/1024)}')

echo $(date) Mission $MBlimit MB. Accomplished $FMB MB \($FGB GB\). Thanks!
