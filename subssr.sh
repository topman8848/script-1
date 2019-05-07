#!/bin/bash
# Usage:
#  bash <(curl -s https://raw.githubusercontent.com/mixool/script/master/subssr.sh)
#  wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/master/subssr.sh && chmod +x subssr.sh && ./subssr.sh

declare -A MY_SS_DIC
declare -A MY_SSR_DIC
declare -A SUB_URL_DIC

######################################################## EDIT BELOW ########################################################
#group name
GROUP="FREE"

#subscriptions
SUB_URL_DIC=( \
	    [ImLaoD]="https://raw.githubusercontent.com/ImLaoD/sub/master/ssrshare.com" \
	    [AmazingDM]="https://raw.githubusercontent.com/AmazingDM/sub/master/ssrshare.com" \
	)
	
#ssr !!! MUST SET THE SAME $GROUP !!!
MY_SSR_DIC=( \
	    [ap]="ssr://MjMuNC4xNzcuMTA6MTM4MzI6b3JpZ2luOmNoYWNoYTIwOnBsYWluOmRHVnpkQS8_b2Jmc3BhcmFtPSZyZW1hcmtzPWJubGomZ3JvdXA9UmxKRlJR" \
	    [us]="ssr://MTUzLjE2LjIzLjE3OjE3MDE6b3JpZ2luOmNoYWNoYTIwOjpkR1Z6ZEEvP29iZnNwYXJhbT0mcmVtYXJrcz1jMmMmZ3JvdXA9UmxKRlJR" \
	)

#ss  !!! PLUGINS AND ENCYPTIONS NOT SUPPORTED BY SSR WILL NOT WORK !!!
MY_SS_DIC=( \
	    [t]="ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpwMVR6blplR091aDJMdEJSZFZoMVdjbTg1S04vN1loSnRPZFR2Qyt1ZlpkSCtqTW41UXpySnp5SUhuVlV2ZitoQDE3Mi4yNDUuMTU4LjExOTo4NTMw#streisand" \
	    [s]="ss://Y2hhY2hhMjA6VEVTVE1FQDIxMy4xOTAuMjAuNjU6MTM4MDA=#anch" \
	    [c]="ss://Y2hhY2hhMjA6bS5zbGllci5uZXQ@0.0.0.0:443/?plugin=obfs-local%3bobfs%3dtls#phonix-tls" \
	)	
######################################################## EDIT ABOVE ########################################################

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

ss_ssr(){
	    MY_SS_LIST=($(echo ${MY_SS_DIC[*]}))
	
	    for(( i=0;i<${#MY_SS_LIST[@]};i++)) do
		SUB_SS_LIST[i]="$(echo "${MY_SS_LIST[i]}" | awk -F'[/@#]+' '{print $2}' | safe_base | base64 -d)"
		IP_PORT[i]="$(echo "${SUB_SS_LIST[i]}" | awk -F'[@]+' '{print $NF}')"
		METHOD[i]="$(echo "${SUB_SS_LIST[i]}" | awk -F'[:]+' '{print $1}')"
		PASSWD[i]="$(echo "${SUB_SS_LIST[i]}" | sed "s/@${IP_PORT[i]}$//" | sed "s/^${METHOD[i]}://")"
		PASSWD_BASE[i]="$(echo -n "${PASSWD[i]}" | base64 | no_n_base | base_safe)"
		BASE_RR[i]="$(echo -n "${IP_PORT[i]}:origin:${METHOD[i]}:plain:${PASSWD_BASE[i]}/?obfsparam=&$GROUP_BASE" | base64 | no_n_base | base_safe)"
		MY_SS_SSR[i]="$(echo "ssr://${BASE_RR[i]}")"
	    done
}

sub_ssr(){
	    SUB_URL_LIST=($(echo ${SUB_URL_DIC[*]}))
	
	    for(( i=0;i<${#SUB_URL_LIST[@]};i++)) do
		SUB_CONF[i]="$(wget -t 5 -T 5 -q -O - ${SUB_URL_LIST[i]} | safe_base | base64 -d | awk -F"://" '{print $2}')"
	    done

	    CONF_SSR="$(echo "${SUB_CONF[*]}")"
	    A_CONF_SSR=($(echo $CONF_SSR))

	    for(( i=0;i<${#A_CONF_SSR[@]};i++)) do
		B_CONF_SSR[i]="$(echo "${A_CONF_SSR[i]}" | safe_base | base64 -d)"
	    done

	    for(( i=0;i<${#B_CONF_SSR[@]};i++)) do
		C_CONF_SSR[i]="$(echo "${B_CONF_SSR[i]}" | awk '{gsub(/group=.*/, "'$GROUP_BASE'", $0); print $1}')"
		D_CONF_SSR[i]="$(echo -n "${C_CONF_SSR[i]}" | base64 | no_n_base | base_safe)"
		MY_SUB_SSR[i]="$(echo "ssr://${D_CONF_SSR[i]}")"
	    done
}

main(){
	    GROUP_BASE="$(echo group=$(echo -n "$GROUP" | base64 | no_n_base | base_safe))"	
	    ss_ssr
	    sub_ssr
	    MY_SSR_LIST=($(echo ${MY_SSR_DIC[*]}))
	    SSR=(${MY_SS_SSR[*]} ${MY_SSR_LIST[*]} ${MY_SUB_SSR[*]})
	    SUB_SSR="$(echo -n "${SSR[*]}" | base64 | no_n_base | base_safe)"
}

main
echo ${SUB_SSR[*]}
