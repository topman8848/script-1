#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/download.sh | bash
##############################
Url=http://download.alicdn.com/wireless/taobao4android/latest/702757.apk
url=http://cesu.cqwin.com/ddb_update/clientdownload/DTestClientSetupCQ.zip
MBlimit=1024
##############################

MBlimit=$(awk 'BEGIN{printf "%.f\n",('$MBlimit'*1024*1024)}')
Length=$(curl -s -I $Url | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
length=$(curl -s -I $url | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
T=$(awk 'BEGIN{printf int('$MBlimit'/'$Length')}')
t=$(awk 'BEGIN{printf int('$MBlimit'%'$Length'/'$length')}')
FMB=$(awk 'BEGIN{printf "%.4f\n",(('$MBlimit'-('$MBlimit'%'$Length'%'$length'))/1024/1024)}')
FGB=$(awk 'BEGIN{printf "%.4f\n",(('$MBlimit'-('$MBlimit'%'$Length'%'$length'))/1024/1024/1024)}')

for((i = 1; i <= T; i++))
do
	echo Downloading $i...
	curl -o /dev/null $Url
	Total=$(awk 'BEGIN{printf ('$i'*'$Length')}')
	MBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$Length'/1024/1024)}')
	GBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$Length'/1024/1024/1024)}')
	echo $MBtotal MB had been downloaded, That is about $GBtotal GB.
done

for((j = 1; j <= t; j++))
do
	echo Still downloading...
	curl -s -o /dev/null $url
done

echo $FMB MB had been downloaded, It is about $FGB GB. Thanks!
