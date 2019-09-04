#!/bin/bash
# Usage:
#  bash <(curl -s https://raw.githubusercontent.com/mixool/script/master/mgwget.sh)

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

#contId
searchType=(1004 1006 500424)
k=$(($RANDOM%${#searchType[*]}))
try_searchType=${searchType[k]}
contId=($(echo $(wget -U "$UA" -T 3 -t 3 -qO- "https://m.miguvideo.com/wap/resource/pc/data/filmLibraryData.jsp?type=1&searchType=${try_searchType}&searchLimit=1002601%2C1002581&pageSize=100" | grep -oE "contentId=[0-9]*" | awk -F'[=]' '{print $NF}' | sort -u) | tr '/n' ' '))

#
limit=$(awk 'BEGIN{printf "%.f\n",('$MBlimit'*1024*1024)}')
Limit=$limit

echo $(date) Mission $MBlimit MB ...
printf "%-20s %-20s %-20s\n" "File(MB)" Speed  "Total(MB)"

for((i = 1; i >= 1; i++))
	do
		j=$(($RANDOM%${#contId[*]}))
		try_contId=${contId[j]}
		
		url="$(wget -U "$UA" -T 1 -t 3 -qO- "http://www.miguvideo.com/gateway/playurl/v3/play/playurl?contId=${try_contId}" | grep -oE "http://.*\.mp4\?msisdn=[^\"]*" | tail -1 | awk -F'["]' '{print $NF}')"
		siz=$(wget -U "$UA" -T 1 -t 3 -qO- "http://www.miguvideo.com/gateway/playurl/v3/play/playurl?contId=${try_contId}" | grep -oE "fileSize[^,]*" | tail -1 | cut -f3 -d"\"")
		[ "$url" == "" -o "$siz" == "" ] && continue
		[[ $((limit-siz)) -lt 0 ]] && break
		
		s=$(wget -U "$UA" -T 1 -t 3 -SO- "$url" 2>&1 >/dev/null | grep -E "written to stdout" | awk -F"[written]" '{print $1}' | awk -F"[\(\)]" '{print $((NF-1))}')
		[[ $s == "" ]] && continue
		limit=$[$limit-$siz]
		printf "%-20s %-20s %-20s\n" $(awk 'BEGIN{printf "%.1f\n",('$siz'/1024/1024)}') "$s" $(awk 'BEGIN{printf "%.1f\n",(('$Limit'-'$limit')/1024/1024)}')
done

FMB=$(awk 'BEGIN{printf "%.2f\n",(('$Limit'-'$limit')/1024/1024)}')
FGB=$(awk 'BEGIN{printf "%.3f\n",(('$Limit'-'$limit')/1024/1024/1024)}')

echo $(date) Mission $MBlimit MB. Accomplished $FMB MB \($FGB GB\). Thanks!
