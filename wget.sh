#!/bin/bash
# Usage:
#   bash <(curl -s https://raw.githubusercontent.com/mixool/script/master/wget.sh)
##  wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/master/wget.sh && chmod +x wget.sh && ./wget.sh
### Total download depends on MBlimit, precision depends on url, speed depends on Url, change them if necessary.
MBlimit=1024
url=http://gxiami.alicdn.com/xiami-desktop/update/XiamiMac-01311741.dmg
Url=http://download.alicdn.com/dingtalk-desktop/mac_dmg/Release/DingTalk_v4.6.13.1.dmg
UA="Mozilla/5.0 (Linux; Android 5.1; OPPO R9m Build/LMY47I; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/72.0.3626.105 Mobile Safari/537.36"
#url=http://partner.iread.wo.com.cn/wonderfulapp/10118/apps/yuexianghui.apk
#Url=http://iread.wo.com.cn/download/channelclient/113/624/woreader_28000000.apk
#############################################################################################################

MB=$MBlimit
MBlimit=$(awk 'BEGIN{printf "%.f\n",('$MBlimit'*1024*1024)}')
length=$(wget --spider -U "$UA" $url -SO- /dev/null 2>&1 | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
Length=$(wget --spider -U "$UA" $Url -SO- /dev/null 2>&1 | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
t=$(awk 'BEGIN{printf int('$MBlimit'%'$Length'/'$length')}')
T=$(awk 'BEGIN{printf int('$MBlimit'/'$Length')}')
FMB=$(awk 'BEGIN{printf "%.4f\n",(('$MBlimit'-('$MBlimit'%'$Length'%'$length'))/1024/1024)}')
FGB=$(awk 'BEGIN{printf "%.4f\n",(('$MBlimit'-('$MBlimit'%'$Length'%'$length'))/1024/1024/1024)}')

if [ "$t" -gt 0 ]; then
	echo `date` - `echo $(echo $url | awk -F"/" '{print $NF}')` will be downloaded $t times...
fi

for((i = 1; i <= t; i++))
do
	s=$(wget -U "$UA" -SO- $url 2>&1 >/dev/null | grep -E "written to stdout" | awk -F"[written]" '{print $1}')
	total=$(awk 'BEGIN{printf ('$i'*'$length')}')
	mBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$length'/1024/1024)}')
	gBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$length'/1024/1024/1024)}')
	echo $s $i - $mBtotal MB \($gBtotal GB\)
done

if [ "$T" -gt 0 ]; then
	echo `date` - `echo $(echo $Url | awk -F"/" '{print $NF}')` will be downloaded $T times...
fi

for((j = 1; j <= T; j++))
do
	S=$(wget -U "$UA" -SO- $Url 2>&1 >/dev/null | grep -E "written to stdout" | awk -F"[written]" '{print $1}')
	Total=$(awk 'BEGIN{printf ('$j'*'$Length')}')
	MBtotal=$(awk 'BEGIN{printf "%.4f\n",('$j'*'$Length'/1024/1024)}')
	GBtotal=$(awk 'BEGIN{printf "%.4f\n",('$j'*'$Length'/1024/1024/1024)}')
	echo $S $j - $MBtotal MB \($GBtotal GB\)
done

echo `date` Mission $MB MB. Accomplished $FMB MB \($FGB GB\). Thanks!
