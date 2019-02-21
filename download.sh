#!binbash
Url=http://download.alicdn.com/wireless/taobao4android/latest/702757.apk
for((i = 1; i >= 1; i++))
do
	echo Downloading $i...
  Length=$(wget -SO- $Url 2>&1 >/dev/null | grep -oE "Content-Length: [0-9]+" | grep -oE "[0-9]+")
	MBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$Length'/1024/1024)}')
	GBtotal=$(awk 'BEGIN{printf "%.4f\n",('$i'*'$Length'/1024/1024/1024)}')
	echo $MBtotal MB had been downloaded. That is about $GBtotal GB.
done
