#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/bashcURL.sh | bash
##  wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/master/bashcURL.sh && chmod +x bashcURL.sh && ./bashcURL.sh
MBlimit=1024
bashcURL=""
cmd1="$bashcURL -I -s"
cmd2="$bashcURL -o /dev/null"
Length=$(eval $cmd1 | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")

for((i = 1; i >= 1; i++))
do
	echo Downloading $i...
	eval $cmd2
	Total=$(awk 'BEGIN{printf ('$i'*'$Length')}')
	Ltotal=$(awk 'BEGIN{printf "%.f\n",('$MBlimit'*1024*1024-'$Length')}')
	MBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$Length'/1024/1024)}')
	GBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$Length'/1024/1024/1024)}')
	
	if [ "$Ltotal" -lt "$Total" ]
	then
	echo $MBtotal MB had been downloaded, That is about $GBtotal GB, Thanks!
	break
	fi
	echo $MBtotal MB had been downloaded, That is about $GBtotal GB.
	
done
