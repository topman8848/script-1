#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/bashcURL.sh | bash
##  wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/master/bashcURL.sh && chmod +x bashcURL.sh && ./bashcURL.sh

#
limit_MB=1000
bashcURL=""

#
limit=$(awk 'BEGIN{printf "%.f\n",('$limit_MB'*1024*1024)}')
Length=$(eval $bashcURL -I -s | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
Length_MB=$(awk 'BEGIN{printf "%.1f\n",('$Length'/1024/1024)}')
T=$(awk 'BEGIN{printf int('$limit'/'$Length')}')
FMB=$(awk 'BEGIN{printf "%.2f\n",(('$limit'-('$limit'%'$Length'))/1024/1024)}')
FGB=$(awk 'BEGIN{printf "%.3f\n",(('$limit'-('$limit'%'$Length'))/1024/1024/1024)}')

if [ "$T" -gt 0 ]; then
	echo $(date) Mission $limit_MB MB. $Length_MB MB will be downloaded $T times...
	for((i = 1; i <= T; i++))
	do
		echo; echo $(awk 'BEGIN{printf "%.1f\n",('$i'*'$Length'/1024/1024)}') MB $i...
		eval $bashcURL -o /dev/null
	done
	echo
fi

echo $(date) Mission $limit_MB MB. Accomplished $FMB MB \($FGB GB\). Thanks!
