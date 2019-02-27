#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/curl.sh | bash
###Total download depends on MBlimit,speed depends on Url,precision depends on url，change them if necessary.
MBlimit=300
Url=http://download.alicdn.com/wireless/taobao4android/latest/702757.apk
url=http://cesu.cqwin.com/ddb_update/clientdownload/DTestClientSetupCQ.zip
#############################################################################################################

MBlimit=$(awk 'BEGIN{printf "%.f\n",('$MBlimit'*1024*1024)}')
Length=$(curl -s -I $Url | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
length=$(curl -s -I $url | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
t=$(awk 'BEGIN{printf int('$MBlimit'%'$Length'/'$length')}')
T=$(awk 'BEGIN{printf int('$MBlimit'/'$Length')}')
FMB=$(awk 'BEGIN{printf "%.2f\n",(('$MBlimit'-('$MBlimit'%'$Length'%'$length'))/1024/1024)}')
FGB=$(awk 'BEGIN{printf "%.3f\n",(('$MBlimit'-('$MBlimit'%'$Length'%'$length'))/1024/1024/1024)}')

if [ "$t" -gt 0 ]; then
	echo $(date) $(echo $url | awk -F"/" '{print $NF}') - $(awk 'BEGIN{printf "%.1f\n",('$length'/1024/1024)}') MB will be downloaded $t times...
	for((i = 1; i <= t; i++))
	do
		echo -n $i.
		curl -s -o /dev/null $url
	done
	echo
	echo $(date) - $t - $(awk 'BEGIN{printf "%.1f\n",('$t'*'$length'/1024/1024)}') MB.
	echo
fi

if [ "$T" -gt 0 ]; then
	echo $(date) $(echo $Url | awk -F"/" '{print $NF}') - $(awk 'BEGIN{printf "%.1f\n",('$Length'/1024/1024)}') MB will be downloaded $T times...
	for((j = 1; j <= T; j++))
	do
		echo
		curl -o /dev/null $Url
		echo $(date) - $j - $(awk 'BEGIN{printf "%.1f\n",('$j'*'$Length'/1024/1024)}') MB.
		echo
	done
fi

echo $(date) Mission $(awk 'BEGIN{printf "%.f\n",('$MBlimit'/1024/1024)}') MB. Accomplished $FMB MB \($FGB GB\) . Thanks! 
