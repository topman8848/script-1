#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# Usage:
## wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/debian-9/daySign_LT.sh && chmod +x daySign_LT.sh && bash daySign_LT.sh
### bash <(curl -s https://raw.githubusercontent.com/mixool/script/debian-9/daySign_LT.sh) ${username} ${password}

# user info: change them to yours or use parameters instead.
username="$1"
password="$2"

# deviceId: if you failed to login , maybe you need to change it to your IMEI.
deviceId=$(shuf -i 123456789012345-987654321012345 -n 1)

# urls
login_url="http://m.client.10010.com/mobileService/login.htm"
logout_url="https://m.client.10010.com/mobileService/logout.htm"
query_url="https://act.10010.com/SigninApp/signin/querySigninActivity.htm"
sign_url="https://act.10010.com/SigninApp/signin/daySign.do"
gold_url="https://act.10010.com/SigninApp/signin/goldTotal.do"

# workdir
workdir="/root/daySign_LT"
[[ ! -d "$workdir" ]] && mkdir $workdir

function rsaencrypt() {
  cat > $workdir/rsa_public.key <<-EOF
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDc+CZK9bBA9IU+gZUOc6
FUGu7yO9WpTNB0PzmgFBh96Mg1WrovD1oqZ+eIF4LjvxKXGOdI79JRdve9
NPhQo07+uqGQgE4imwNnRx7PFtCRryiIEcUoavuNtuRVoBAm6qdB0Srctg
aqGfLgKvZHOnwTjyNqjBUxzMeQlEC2czEMSwIDAQAB
-----END PUBLIC KEY-----
EOF

  crypt_username=$(echo -n $username | openssl rsautl -encrypt -inkey $workdir/rsa_public.key -pubin -out >(base64 | tr "\n" " " | sed s/[[:space:]]//g))
  crypt_password=$(echo -n $password | openssl rsautl -encrypt -inkey $workdir/rsa_public.key -pubin -out >(base64 | tr "\n" " " | sed s/[[:space:]]//g))
}

function urlencode() {
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
		[a-zA-Z0-9.~_-]) printf "$c" ;;
		*) printf "$c" | xxd -p -c1 | while read x;do printf "%%%s" "$x";done
    esac
  done
}

function daySign() {
    rsaencrypt
    cat > $workdir/signdata <<-EOF
isRemberPwd=true
&deviceId=$deviceId
&password=$(urlencode $crypt_password)
&netWay=Wifi
&mobile=$(urlencode $crypt_username)
&yw_code: 
&timestamp=$(date +"%Y-%m-%d_%H-%M-%S" | awk -F'[-_-]' '{print $1$2$3$4$5$6}')
&appId=dda726c5e6aa1ee96e62a88ecae46f11635696d85fc21cff4333b0eded85fc21dd4177d8ee50e52b977ee1d25e032b961585631b4fc010c2f1ac8c8e04a6791e
&keyVersion:
&deviceBrand=Oneplus
&pip=10.0.10.10
&provinceChanel=general
&version=android%406.0100
&deviceModel=oneplus%20a5010
&deviceOS=android6.0.1
&deviceCode=$deviceId
EOF

  # on_token cookies
  curl -s -D $workdir/on_token $logout_url >/dev/null
  
  # cookie_a cookie_b
  curl -s -b $workdir/on_token -c $workdir/cookie_a -d @$workdir/signdata $login_url >/dev/null
  token=$(cat $workdir/cookie_a | grep -E "a_token" | awk  '{print $7}')
  [[ "$token" = "" ]] && echo "Error, starting failed." && rm -rf $workdir && exit 1
  echo 
  echo $(date) starting daySign...
  curl -s -b $workdir/cookie_a -c $workdir/cookie_b --data "token=$token" $query_url >/dev/null

  # goldTotal_before
  echo goldTotal_before：$(curl -s -b $workdir/cookie_b $gold_url)

  # daySign_status
  echo daySign_status： $(curl -s -b $workdir/cookie_b $sign_url)
  
  # weiboSign_status
  timestamp=$(date +"%Y-%m-%d_%H-%M-%S" | awk -F'[-_-]' '{print $1$2$3$4$5$6}')
  random_weibo_stamp=$(shuf -i 123456789012345-987654321012345 -n 1)
  echo weiboSign_status：$(curl -s -b $workdir/cookie_b --data "transId=$timestamp$(shuf -i 0-9 -n 1).$random_weibo_stamp&userNumber=$username&taskCode=TA590934984&finishTime=$timestamp&taskType=DAILY_TASK" https://act.10010.com/signinAppH/commonTask)

  # goldTotal_now
  echo goldTotal_now：$(curl -s -b $workdir/cookie_b $gold_url)
}

function doubleball() {
  # doubleball: 3 times free each day. need cookie_b
  usernumberofjsp=$(curl -s -b $workdir/cookie_b http://m.client.10010.com/dailylottery/static/textdl/userLogin | grep -oE "encryptmobile=\w*" | awk -F"encryptmobile=" '{print $2}')
  echo 
  echo $(date) starting doubleball...
  echo 1st： $(curl -s -b $workdir/cookie_b --data "usernumberofjsp=$usernumberofjsp" http://m.client.10010.com/dailylottery/static/doubleball/choujiang) ; sleep 3
  echo 2nd： $(curl -s -b $workdir/cookie_b --data "usernumberofjsp=$usernumberofjsp" http://m.client.10010.com/dailylottery/static/doubleball/choujiang) ; sleep 3
  echo 3rd： $(curl -s -b $workdir/cookie_b --data "usernumberofjsp=$usernumberofjsp" http://m.client.10010.com/dailylottery/static/doubleball/choujiang) ; sleep 3
}


function arborday() {
  # arborday: 1 time free each day. need cookie_a
  echo 
  echo $(date) starting arbor day...
  timestamp=$(date +"%Y-%m-%d_%H-%M-%S" | awk -F'[-_-]' '{print $1$2$3$4$5$6}')
  curl -s -b $workdir/cookie_a -c $workdir/cookie_ar.txt --data "timestamp=$timestamp&desmobile=$username&version=android%406.0100" https://m.client.10010.com/mactivity/arborday/index >/dev/null ; sleep 3
  curl -s -b $workdir/cookie_ar.txt https://m.client.10010.com/mactivity/arborday/arbor/1/0/1/grow
}

function wangzuan() {
  # wangzuan: 1 time free each month. need cookie_a
  [[ $(date | awk '{print $3}') -eq 1 ]] || return 0
  echo 
  echo $(date) starting wangzuan...
  timestamp=$(date +"%Y-%m-%d_%H-%M-%S" | awk -F'[-_-]' '{print $1$2$3$4$5$6}')
  curl -L -s -b $workdir/cookie_a -c $workdir/cookie_wa.txt --data "timestamp=$timestamp&desmobile=$username&version=android%406.0100" "https://m.client.10010.com/mobileService/openPlatform/openPlatLine.htm?to_url=https://wangzuan.10010.com/api/auth/login?source=2" >/dev/null ; sleep 3 
  echo wangzuan_status：$(curl -X POST -s -b $workdir/cookie_wa.txt https://wangzuan.10010.com/api/activity/lottery)
}

function member() {
  # newsId share and incrComment 3 times free each day. need cookie_a
  echo 
  echo $(date) starting member points...
  newsId=$(curl -s -b $workdir/cookie_a https://m.client.10010.com/mobileService/customer/getQuickNewsInfo.htm | grep -oE "id=\w*" | awk -F"id=" '{print $2}' | sed -n '1p')
  echo newsId_1st：$(curl -s -b $workdir/cookie_a --data "newsId=$newsId" "http://m.client.10010.com/mobileService/customer/quickNews/shareSuccess.htm") ; sleep 3
  echo incrComment_1st：$(curl -s -b $workdir/cookie_a --data "target=$newsId" https://m.client.10010.com/mobileService/customer/query/quickNews/incrCommentTimes.htm); sleep 3
  
  newsId=$(curl -s -b $workdir/cookie_a https://m.client.10010.com/mobileService/customer/getQuickNewsInfo.htm | grep -oE "id=\w*" | awk -F"id=" '{print $2}' | sed -n '2p')
  echo newsId_2nd：$(curl -s -b $workdir/cookie_a --data "newsId=$newsId" "http://m.client.10010.com/mobileService/customer/quickNews/shareSuccess.htm") ; sleep 3
  echo incrComment_2nd：$(curl -s -b $workdir/cookie_a --data "target=$newsId" https://m.client.10010.com/mobileService/customer/query/quickNews/incrCommentTimes.htm); sleep 3
  
  newsId=$(curl -s -b $workdir/cookie_a https://m.client.10010.com/mobileService/customer/getQuickNewsInfo.htm | grep -oE "id=\w*" | awk -F"id=" '{print $2}' | sed -n '3p')
  echo newsId_3rd：$(curl -s -b $workdir/cookie_a --data "newsId=$newsId" "http://m.client.10010.com/mobileService/customer/quickNews/shareSuccess.htm") ; sleep 3
  echo incrComment_3rd：$(curl -s -b $workdir/cookie_a --data "target=$newsId" https://m.client.10010.com/mobileService/customer/query/quickNews/incrCommentTimes.htm); sleep 3
}

function openChg() {
  # openChg for dingding 1 time each month. need cookie_a.
  [[ $(date | awk '{print $3}') -eq 1 ]] || return 0
  echo 
  echo $(date) starting dingding OpenChg...
  curl -s -b $workdir/cookie_a --data "querytype=02&opertag=0" "https://m.client.10010.com/mobileService/businessTransact/serviceOpenCloseChg.htm" >/dev/null
}

function main() {
  sleep $(shuf -i 1-10800 -n 1)
  daySign
  doubleball
  arborday
  wangzuan
  member
  openChg
  
  # clean
  rm -rf $workdir

  # exit
  echo 
  echo $(date) $username Accomplished.  Thanks!
}

main
