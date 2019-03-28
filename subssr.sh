#!/bin/bash
# Usage:
#  bash <(curl -s https://raw.githubusercontent.com/mixool/script/master/subssr.sh)
#  wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/master/subssr.sh && chmod +x subssr.sh && ./subssr.sh

declare -A SUB_URL_DIC
declare -A MY_SSR_DIC

######################################################## EDIT Below ########################################################
#group name
GROUP="FREE"

#ssr !!! must set the same $GROUP !!!
MY_SSR_DIC=( \
		[ap]="ssr://MjMuNC4xNzcuMTA6MTM4MzI6b3JpZ2luOmNoYWNoYTIwOnBsYWluOmRHVnpkQS8_b2Jmc3BhcmFtPSZyZW1hcmtzPWJubGomZ3JvdXA9UmxKRlJR" \
		[us]="ssr://MTUzLjE2LjIzLjE3OjE3MDE6b3JpZ2luOmNoYWNoYTIwOjpkR1Z6ZEEvP29iZnNwYXJhbT0mcmVtYXJrcz1jMmMmZ3JvdXA9UmxKRlJR" \
	)
#subscriptions
SUB_URL_DIC=( \
		[ImLaoD]="https://raw.githubusercontent.com/ImLaoD/sub/master/ssrshare.com" \
		[AmazingDM]="https://raw.githubusercontent.com/AmazingDM/sub/master/ssrshare.com" \
	)
######################################################## EDIT Above ########################################################

#base64_safe_url_base64_no_n
BASE_CHARS="+/="
SAFE_CHARS="-_ "
base_safe(){
			tr -- "${BASE_CHARS}" "${SAFE_CHARS}" | sed -e 's/ *$//g'
}

safe_base(){
			awk '{ L=length($1)/4; L=int((L==int(L))?L:int(L)+1)*4; printf "%-*s\n", L, $1; }' | tr -- "${SAFE_CHARS}" "${BASE_CHARS}"
}

no_n_base(){
			tr "\n" " " | sed s/[[:space:]]//g
}

main(){
		GROUP_BASE="$(echo group=$(echo -n "$GROUP" | base64 | no_n_base | base_safe))"	
		SUB_URL_LIST=($(echo ${SUB_URL_DIC[*]}))
		MY_SSR_LIST=($(echo ${MY_SSR_DIC[*]}))
	
		for(( i=0;i<${#SUB_URL_LIST[@]};i++)) do
			SUB_CONF[i]="$(wget -t 5 -T 5 -q -O - ${SUB_URL_LIST[i]} | safe_base | base64 -d | awk -F"://" '{print $2}')"
		done

		CONF_SSR="$(echo "${SUB_CONF[*]}")"
		ARR_CONF_SSR=($(echo $CONF_SSR))

		for(( i=0;i<${#ARR_CONF_SSR[@]};i++)) do
			BRR_CONF_SSR[i]="$(echo "${ARR_CONF_SSR[i]}" | safe_base | base64 -d)"
		done

		for(( i=0;i<${#BRR_CONF_SSR[@]};i++)) do
			CRR_CONF_SSR[i]="$(echo "${BRR_CONF_SSR[i]}" | awk '{gsub(/group=.*/, "'$GROUP_BASE'", $0); print $1}')"
			DRR_CONF_SSR[i]="$(echo -n "${CRR_CONF_SSR[i]}" | base64 | no_n_base | base_safe)"
			ERR_CONF_SSR[i]="$(echo "ssr://${DRR_CONF_SSR[i]}")"
		done

		FRR_CONF_SSR=(${ERR_CONF_SSR[*]}  ${MY_SSR_LIST[*]})
		SUB_SSR="$(echo -n "${FRR_CONF_SSR[*]}" | base64 | no_n_base | base_safe)"
}

main
echo $SUB_SSR
