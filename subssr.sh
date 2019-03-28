#!/bin/bash
# Usage:
#  bash <(curl -s https://raw.githubusercontent.com/mixool/script/master/subssr.sh)
#  wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/master/subssr.sh && chmod +x subssr.sh && ./subssr.sh

SUB_URL=( \
	"https://raw.githubusercontent.com/ImLaoD/sub/master/ssrshare.com" \
	"https://raw.githubusercontent.com/AmazingDM/sub/master/ssrshare.com" \
	)
	
GROUP="FREE"

#ADD YOUR SSR (Must set the same $GROUP)
MY_SSR=( \
	"ssr://dXMuamtpLmFwcDo5Om9yaWdpbjphZXMtMTkyLWN0cjpwbGFpbjpRVE15TkRJek5ESTAvP29iZnNwYXJhbT0mZ3JvdXA9UmxKRlJR" \
	"ssr://cy51a2kuYXBwOjk6b3JpZ2luOnJjNDpwbGFpbjpRVE15TkRJek5ESTAvP29iZnNwYXJhbT0mZ3JvdXA9UmxKRlJR" \
	)

#base64_safe_url_no_n
BASE_CHARS="+/="
SAFE_CHARS="-_ "
function base_safe {
    tr -- "${BASE_CHARS}" "${SAFE_CHARS}" | sed -e 's/ *$//g'
}

function safe_base {
    awk '{ L=length($1)/4; L=int((L==int(L))?L:int(L)+1)*4; printf "%-*s\n", L, $1; }' | tr -- "${SAFE_CHARS}" "${BASE_CHARS}"
}

function no_n_base {
    tr "\n" " " | sed s/[[:space:]]//g
}

function main {
	for(( i=0;i<${#SUB_URL[@]};i++)) do
		SUB_CONF[i]="$(wget -t 5 -T 5 -q -O - ${SUB_URL[i]} | safe_base | base64 -d | awk -F"://" '{print $2}')"
	done

	CONF_SSR="$(echo "${SUB_CONF[*]}")"
	ARR_CONF_SSR=($(echo $CONF_SSR))
	GROUP_BASE="$(echo group=$(echo -n "$GROUP" | base64 | no_n_base | base_safe))"

	for(( i=0;i<${#ARR_CONF_SSR[@]};i++)) do
		BRR_CONF_SSR[i]="$(echo "${ARR_CONF_SSR[i]}" | safe_base | base64 -d)"
	done

	for(( i=0;i<${#BRR_CONF_SSR[@]};i++)) do
		CRR_CONF_SSR[i]="$(echo "${BRR_CONF_SSR[i]}" | awk '{gsub(/group=.*/, "'$GROUP_BASE'", $0); print $1}')"
		DRR_CONF_SSR[i]="$(echo -n "${CRR_CONF_SSR[i]}" | base64 | no_n_base | base_safe)"
		ERR_CONF_SSR[i]="$(echo "ssr://${DRR_CONF_SSR[i]}")"
	done

	FRR_CONF_SSR=(${ERR_CONF_SSR[*]}  ${MY_SSR[*]})
	SUB_SSR="$(echo -n "${FRR_CONF_SSR[*]}" | base64 | no_n_base | base_safe)"
}

main
echo $SUB_SSR
