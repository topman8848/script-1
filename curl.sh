#!/bin/bash
# Usage:
#   bash <(curl -s https://raw.githubusercontent.com/mixool/script/master/curl.sh)
##  wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/master/curl.sh && chmod +x curl.sh && ./curl.sh
### Total download depends on MBlimit, precision depends on url, speed depends on Url, change them if necessary.
MBlimit=1024
url=http://gxiami.alicdn.com/xiami-desktop/update/XiamiMac-01311741.dmg
Url=http://download.alicdn.com/dingtalk-desktop/mac_dmg/Release/DingTalk_v4.6.13.1.dmg
UA="Mozilla/5.0 (Linux; Android 5.1; OPPO R9m Build/LMY47I; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/72.0.3626.105 Mobile Safari/537.36"
#url=http://partner.iread.wo.com.cn/wonderfulapp/10118/apps/yuexianghui.apk
#Url=http://iread.wo.com.cn/download/channelclient/113/624/woreader_28000000.apk
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
