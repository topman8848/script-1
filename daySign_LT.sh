#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
# Usage:
## wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/debian-9/daySign_LT.sh && chmod +x daySign_LT.sh && bash daySign_LT.sh
### bash <(curl -s https://raw.githubusercontent.com/mixool/script/debian-9/daySign_LT.sh) ${username} ${password}

# info_user: change them to yours or use parameters instead.
username="$1"
password="$2"

# deviceId: if you failed to login , maybe you need to change it to your IMEI.
deviceId="213313966308801"

# urls
login_url="http://m.client.10010.com/mobileService/login.htm"
query_url="https://act.10010.com/SigninApp/signin/querySigninActivity.htm"
sign_url="https://act.10010.com/SigninApp/signin/daySign.do"
gold_url="https://act.10010.com/SigninApp/signin/goldTotal.do"

function rsaencrypt() {
  cat > /tmp/rsa_public.key <<-EOF
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDc+CZK9bBA9IU+gZUOc6
FUGu7yO9WpTNB0PzmgFBh96Mg1WrovD1oqZ+eIF4LjvxKXGOdI79JRdve9
NPhQo07+uqGQgE4imwNnRx7PFtCRryiIEcUoavuNtuRVoBAm6qdB0Srctg
aqGfLgKvZHOnwTjyNqjBUxzMeQlEC2czEMSwIDAQAB
-----END PUBLIC KEY-----
EOF

  crypt_username=$(echo -n $username | openssl rsautl -encrypt -inkey /tmp/rsa_public.key -pubin -out >(base64 | tr "\n" " " | sed s/[[:space:]]//g))
  crypt_password=$(echo -n $password | openssl rsautl -encrypt -inkey /tmp/rsa_public.key -pubin -out >(base64 | tr "\n" " " | sed s/[[:space:]]//g))
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
  urlencode_username=$(urlencode $crypt_username)
  urlencode_password=$(urlencode $crypt_password)
  timestamp=$(date +"%Y-%m-%d_%H-%M-%S" | awk -F'[-_-]' '{print $1$2$3$4$5$6}')
  random_weibo_stamp=$(shuf -i 1533965577286299-9533965577286299 -n 1)

    cat > /tmp/signdata <<-EOF
isRemberPwd=true
&deviceId=$deviceId
&password=$urlencode_password
&netWay=Wifi
&mobile=$urlencode_username
&yw_code: 
&timestamp=$timestamp
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

  # querySigninActivity cookies
  curl -s -D ./cookie_D.txt -d @/tmp/signdata $login_url >/dev/null
  token=$(cat ./cookie_D.txt | grep -oE "a_token=.*" | awk -F"a_token=" '{print $2}')
  [[ "$token" = "" ]] && echo "Error, starting daySign failed." && exit 1
  echo 
  echo $(date) starting daySign...
  curl -s -b ./cookie_D.txt -c ./cookie_E.txt --data "token=$token" $query_url >/dev/null

  # goldTotal_before
  echo goldTotal_before：$(curl -s -b ./cookie_E.txt $gold_url)

  # daySign_status
  echo daySign_status： $(curl -s -b ./cookie_E.txt $sign_url)
  
  # weiboSign_status
  echo weiboSign_status：$(curl -s -b ./cookie_E.txt --data "transId=$timestamp.$(date +%s%N)&userNumber=$username&taskCode=TA590934984&finishTime=$timestamp&taskType=DAILY_TASK" https://act.10010.com/signinAppH/commonTask)

  # goldTotal_now
  echo goldTotal_now：$(curl -s -b ./cookie_E.txt $gold_url)
}

function doubleball() {
  # doubleball: 3 times free each day.
  usernumberofjsp=$(curl -s -b ./cookie_E.txt  -c ./cookie_F.txt http://m.client.10010.com/dailylottery/static/textdl/userLogin | grep -oE "encryptmobile=\w*" | awk -F"encryptmobile=" '{print $2}')
  [[ "$usernumberofjsp" = "" ]] && echo "Error, starting doubleball failed." && exit 1
  echo 
  echo $(date) starting doubleball...
  echo 1st： $(curl -s -b ./cookie_F.txt --data "usernumberofjsp=$usernumberofjsp" http://m.client.10010.com/dailylottery/static/doubleball/choujiang) ; sleep 3
  echo 2nd： $(curl -s -b ./cookie_F.txt --data "usernumberofjsp=$usernumberofjsp" http://m.client.10010.com/dailylottery/static/doubleball/choujiang) ; sleep 3
  echo 3rd： $(curl -s -b ./cookie_F.txt --data "usernumberofjsp=$usernumberofjsp" http://m.client.10010.com/dailylottery/static/doubleball/choujiang) ; sleep 3
}

rsaencrypt
daySign
doubleball

# clean
rm /tmp/rsa_public.key ./cookie_D.txt ./cookie_E.txt ./cookie_F.txt

# exit
echo 
echo $(date) Accomplished. Thanks! && exit 0
