#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
# Usage:
## wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/debian-9/daySign_LT.sh && chmod +x daySign_LT.sh && bash daySign_LT.sh
### bash <(curl -s https://raw.githubusercontent.com/mixool/script/debian-9/daySign_LT.sh) ${username} ${password}

# info_user: change them to yours or use parameters instead.
username="$1"
password="$2"

# deviceId: if you failed to login , you need to change it.
deviceId="008796756028082"

# urls
login_url="http://m.client.10010.com/mobileService/login.htm"
query_url="https://act.10010.com/SigninApp/signin/querySigninActivity.htm"
sign_url="https://act.10010.com/SigninApp/signin/daySign.do"
gold_url="https://act.10010.com/SigninApp/signin/goldTotal.do"

function rsaencrypt() {
  apiurl="http://api.bejson.com/btools/tools/enc/rsa/buildRSAEncryptByPublicKey"
  pubkey="MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDc%2BCZK9bBA9IU%2BgZUOc6FUGu7yO9WpTNB0PzmgFBh96Mg1WrovD1oqZ%2BeIF4LjvxKXGOdI79JRdve9NPhQo07%2BuqGQgE4imwNnRx7PFtCRryiIEcUoavuNtuRVoBAm6qdB0SrctgaqGfLgKvZHOnwTjyNqjBUxzMeQlEC2czEMSwIDAQAB"
  echo $(curl -s -d "key=$pubkey&data=${1}&rsaType=rsa" $apiurl | awk -F'["]' '{print $6}')
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
  echo 
  echo $(date) starting daySign...
  crypt_username=$(rsaencrypt $username)
  crypt_password=$(rsaencrypt $password)

  urlencode_username=$(urlencode $crypt_username)
  urlencode_password=$(urlencode $crypt_password)
  timestamp=$(date +"%Y-%m-%d_%H-%M-%S" | awk -F'[-_-]' '{print $1$2$3$4$5$6}')

  # querySigninActivity
  curl -s -D ./cookie_D.txt --data "isRemberPwd=true&deviceId=$deviceId&password=$urlencode_password&netWay=Wifi&mobile=$urlencode_username&yw_code=&timestamp=$timestamp&appId=dda726c5e6aa1ee96e62a88ecae46f11635696d85fc21cff4333b0eded85fc21dd4177d8ee50e52b977ee1d25e032b961585631b4fc010c2f1ac8c8e04a6791e&keyVersion=&deviceBrand=Oneplus&pip=123.147.248.206&provinceChanel=general&version=android%406.0100&deviceModel=oneplus%20a5010&deviceOS=android6.0.1&deviceCode=$deviceId" $login_url >/dev/null

  token=$(cat ./cookie_D.txt | grep -oE "a_token=.*" | awk -F"a_token=" '{print $2}')
  [[ "$token" = "" ]] && echo "Error,Login failed." && exit 1
  
  curl -s -b ./cookie_D.txt -c ./cookie_E.txt --data "token=$token" $query_url >/dev/null

  # goldTotal_yesterday
  echo goldTotal_yesterday：$(curl -s -b ./cookie_E.txt $gold_url)

  # daySign_status
  echo daySign_status： $(curl -s -b ./cookie_E.txt $sign_url)

  # goldTotal_today
  echo goldTotal_today：$(curl -s -b ./cookie_E.txt $gold_url)
}

function doubleball() {
  # doubleball: 3 times free each day.
  usernumberofjsp=$(curl -s -b ./cookie_E.txt  -c ./cookie_F.txt http://m.client.10010.com/dailylottery/static/textdl/userLogin | grep -oE "encryptmobile=\w*" | awk -F"encryptmobile=" '{print $2}')
  echo 
  echo $(date) starting doubleball...
  echo 1： $(curl -s -b ./cookie_F.txt --data "usernumberofjsp=$usernumberofjsp" http://m.client.10010.com/dailylottery/static/doubleball/choujiang) ; sleep 3
  echo 2： $(curl -s -b ./cookie_F.txt --data "usernumberofjsp=$usernumberofjsp" http://m.client.10010.com/dailylottery/static/doubleball/choujiang) ; sleep 3
  echo 3： $(curl -s -b ./cookie_F.txt --data "usernumberofjsp=$usernumberofjsp" http://m.client.10010.com/dailylottery/static/doubleball/choujiang) ; sleep 3
}

daySign
doubleball

# clean
rm ./cookie_D.txt ./cookie_E.txt ./cookie_F.txt

# exit
echo 
echo $(date) Accomplished daySign_LT.sh. Thanks! && exit 0
