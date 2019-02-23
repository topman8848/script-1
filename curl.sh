#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/curl.sh | bash
###Total download depends on MBlimit,speed depends on Url,precision depends on url，change them if necessary.
MBlimit=1024
Url=http://download.alicdn.com/wireless/taobao4android/latest/702757.apk
url=http://cesu.cqwin.com/ddb_update/clientdownload/DTestClientSetupCQ.zip
#############################################################################################################

MBlimit=$(awk 'BEGIN{printf "%.f\n",('$MBlimit'*1024*1024)}')
Length=$(curl -s -I $Url | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
length=$(curl -s -I $url | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
T=$(awk 'BEGIN{printf int('$MBlimit'/'$Length')}')
t=$(awk 'BEGIN{printf int('$MBlimit'%'$Length'/'$length')}')
FMB=$(awk 'BEGIN{printf "%.4f\n",(('$MBlimit'-('$MBlimit'%'$Length'%'$length'))/1024/1024)}')
FGB=$(awk 'BEGIN{printf "%.4f\n",(('$MBlimit'-('$MBlimit'%'$Length'%'$length'))/1024/1024/1024)}')

if [ "$T" -gt 0 ]; then
	echo `date` Start downloading $Url ...
fi

for((i = 1; i <= T; i++))
do
	echo 
	curl -o /dev/null $Url
	Total=$(awk 'BEGIN{printf ('$i'*'$Length')}')
	MBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$Length'/1024/1024)}')
	GBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$Length'/1024/1024/1024)}')
	echo `date` $MBtotal MB \($GBtotal GB\) had been downloaded. Accomplished $i.
	echo
done

if [ "$t" -gt 0 ]; then
echo -n `date` Start downloading $url ...
fi

for((j = 1; j <= t; j++))
do
	echo -n .
	curl -s -o /dev/null $url
done

if [ "$t" -gt 0 ]; then
total=$(awk 'BEGIN{printf ('$t'*'$length')}')
mBtotal=$(awk 'BEGIN{printf "%.4f\n",('$t'*'$length'/1024/1024)}')
gBtotal=$(awk 'BEGIN{printf "%.4f\n",('$t'*'$length'/1024/1024/1024)}')
echo
echo `date` $mBtotal MB \($gBtotal GB\) had been downloaded. Accomplished $t.
fi

echo
echo `date` Accomplished, $FMB MB \($FGB GB\) had been downloaded. Thanks!
