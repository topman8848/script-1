#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/mixool/script/master/wget.sh | bash
##  wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/master/wget.sh && chmod +x wget.sh && ./wget.sh
### Total download depends on MBlimit, precision depends on url, speed depends on Url, change them if necessary.
MBlimit=1024
url=http://gxiami.alicdn.com/xiami-desktop/update/XiamiMac-01311741.dmg
Url=http://download.alicdn.com/dingtalk-desktop/mac_dmg/Release/DingTalk_v4.6.13.1.dmg
#url=http://cesu.cqwin.com/ddb_update/clientdownload/DTestClientSetupCQ.zip
#############################################################################################################

MBlimit=$(awk 'BEGIN{printf "%.f\n",('$MBlimit'*1024*1024)}')
MB=$(awk 'BEGIN{printf "%.f\n",('$MBlimit'/1024/1024)}')
length=$(wget --spider $url -SO- /dev/null 2>&1 | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
Length=$(wget --spider $Url -SO- /dev/null 2>&1 | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
t=$(awk 'BEGIN{printf int('$MBlimit'%'$Length'/'$length')}')
T=$(awk 'BEGIN{printf int('$MBlimit'/'$Length')}')
FMB=$(awk 'BEGIN{printf "%.4f\n",(('$MBlimit'-('$MBlimit'%'$Length'%'$length'))/1024/1024)}')
FGB=$(awk 'BEGIN{printf "%.4f\n",(('$MBlimit'-('$MBlimit'%'$Length'%'$length'))/1024/1024/1024)}')

if [ "$t" -gt 0 ]; then
	echo `date` Start downloading $url ...
fi

for((i = 1; i <= t; i++))
do
	s=$(wget -SO- $url 2>&1 >/dev/null | grep -E "written to stdout" | awk -F"[written]" '{print $1}')
	total=$(awk 'BEGIN{printf ('$i'*'$length')}')
	mBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$length'/1024/1024)}')
	gBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$length'/1024/1024/1024)}')
	echo $s $i - Downloaded $mBtotal MB \($gBtotal GB\)
done

if [ "$T" -gt 0 ]; then
	echo `date` Start downloading $Url ...
fi

for((j = 1; j <= T; j++))
do
	S=$(wget -SO- $Url 2>&1 >/dev/null | grep -E "written to stdout" | awk -F"[written]" '{print $1}')
	Total=$(awk 'BEGIN{printf ('$j'*'$Length')}')
	MBtotal=$(awk 'BEGIN{printf "%.4f\n",('$j'*'$Length'/1024/1024)}')
	GBtotal=$(awk 'BEGIN{printf "%.4f\n",('$j'*'$Length'/1024/1024/1024)}')
	echo $S $j - Downloaded $MBtotal MB \($GBtotal GB\)
done

MBlimit=$(awk 'BEGIN{printf "%.f\n",('$MBlimit'/1024/1024)}')

echo `date` Mission $MB MB, Accomplished $FMB MB \($FGB GB\). Thanks!
