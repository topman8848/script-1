#!/bin/bash
# Usage:
#  bash <(curl -s https://raw.githubusercontent.com/mixool/script/debian-9/subssr.sh)
#  wget --no-check-certificate https://raw.githubusercontent.com/mixool/script/debian-9/subssr.sh && chmod +x subssr.sh && bash subssr.sh

declare -A my_ss_dic
declare -A my_ssr_dic
declare -A my_sub_dic

######################################################## EDIT BELOW ########################################################
# group name
GROUP="FREE"

# only process ssr links that remarks in/no keywords in the subscription. set others or keep it null.
in_words=()
no_words=(维护 剩余 过期 官网)
obfsparam="cloudflare.com"
url_ip="true"
remarks=""
sub_ssr_random_show="20"

# subscriptions
my_sub_dic=( \
	    [AmazingDM]="https://raw.githubusercontent.com/AmazingDM/sub/master/ssrshare.com" \
	)
	
# ssr !!! MUST SET THE SAME $GROUP !!!
my_ssr_dic=( \
	    [Norway]="ssr://MTg1LjE1LjE3MS4zOjEwNTAxOm9yaWdpbjpjaGFjaGEyMDpwbGFpbjpkR1Z6ZEEvP29iZnNwYXJhbT0mZ3JvdXA9UmxKRlJR" \
	)

# ss  !!! PLUGINS AND ENCYPTIONS NOT SUPPORTED BY SSR WILL NOT WORK !!!
my_ss_dic=( \
        [Norway]="ss://Y2hhY2hhMjA6dGVzdEAxODUuMTUuMTcxLjM6MTA1MDE" \
    )

# result to web server file
file="/var/www/subssr/free"
######################################################## EDIT ABOVE ########################################################

# base64_safe_url_base64_no_n
BASE_CHARS="+/="
SAFE_CHARS="-_ "
function base_safe(){
	tr -- "${BASE_CHARS}" "${SAFE_CHARS}" | sed -e 's/ *$//g'
}

function safe_base(){
	awk '{ L=length($1)/4; L=int((L==int(L))?L:int(L)+1)*4; printf "%-*s\n", L, $1; }' | tr -- "${SAFE_CHARS}" "${BASE_CHARS}"
}

function no_n_base(){
	tr "\n" " " | sed s/[[:space:]]//g
}

function ss_ssr(){
	my_ss_list=($(echo ${my_ss_dic[*]}))
	group_base="$(echo -n group=$(echo -n "$GROUP" | base64 | no_n_base | base_safe))"
  
	for(( i=0;i<${#my_ss_list[@]};i++)) do
		sub_ss_list[i]="$(echo "${my_ss_list[i]}" | awk -F'[/@#]+' '{print $2}' | safe_base | base64 -d)"
		ip_port[i]="$(echo "${sub_ss_list[i]}" | awk -F'[@]+' '{print $NF}')"
		method[i]="$(echo "${sub_ss_list[i]}" | awk -F'[:]+' '{print $1}')"
		passwd[i]="$(echo "${sub_ss_list[i]}" | sed "s/@${ip_port[i]}$//" | sed "s/^${method[i]}://")"
		passwd_base[i]="$(echo -n "${passwd[i]}" | base64 | no_n_base | base_safe)"
		base_rr[i]="$(echo -n "${ip_port[i]}:origin:${method[i]}:plain:${passwd_base[i]}/?obfsparam=&$group_base" | base64 | no_n_base | base_safe)"
		my_ss_ssr[i]="$(echo "ssr://${base_rr[i]}")"
	done
}

function sub_ssr(){
	my_sub_list=($(echo ${my_sub_dic[*]}))
	group_base="$(echo group=$(echo -n "$GROUP" | base64 | no_n_base | base_safe))"
	
	for(( i=0;i<${#my_sub_list[@]};i++)); do
		sub_conf[i]="$(wget -t 5 -T 5 -q -O - ${my_sub_list[i]} | safe_base | base64 -d | awk -F"://" '{print $2}')"
	done

	conf_ssr="$(echo "${sub_conf[*]}")" && a_conf_ssr=($(echo "$conf_ssr"))

	for(( i=0;i<${#a_conf_ssr[@]};i++)); do
		b_conf_ssr[i]="$(echo "${a_conf_ssr[i]}" | safe_base | base64 -d)"
	done

	for(( i=0;i<${#b_conf_ssr[@]};i++)); do
		c_conf_ssr[i]="$(echo "${b_conf_ssr[i]}" | awk '{gsub(/group=.*/, "'$group_base'", $0); print $1}')"
		
		if [ -n "$in_words" ]; then
			for(( j=0;j<${#in_words[@]};j++)); do
				key=$(echo "${c_conf_ssr[i]}" | grep -oE "remarks=.*" | awk -F'[=&]' '{print $2}' | safe_base | base64 -d | grep -oE "${in_words[j]}")
				if [ -n "$key" ]; then d_conf_ssr[i]=${c_conf_ssr[i]}; fi
			done
		else
			d_conf_ssr[i]=${c_conf_ssr[i]}
		fi

		if [ -n "$no_words" ]; then
			for(( k=0;k<${#no_words[@]};k++)); do
				yek=$(echo "${c_conf_ssr[i]}" | grep -oE "remarks=.*" | awk -F'[=&]' '{print $2}' | safe_base | base64 -d | grep -oE "${no_words[k]}")
				if [ -n "$yek" ]; then unset d_conf_ssr[i]; fi
			done
		fi
		
		if [ ! "$url_ip" = "" ]; then
			url[i]="$(echo "${d_conf_ssr[i]}" | awk -F'[:]' '{print $1}')"
			ip[i]="$(echo "${url[i]}" | xargs ping -c 1 2>&1 | awk -F'[()]' 'NR==1{print $2}')"
			d_conf_ssr[i]="$(echo "${d_conf_ssr[i]}" | awk '{gsub("'${url[i]}'", "'${ip[i]}'", $0); print $1}')"
		fi

		if [ ! "$obfsparam" = "" ]; then
			obfsparam_base="$(echo -n "$obfsparam" | base64 | no_n_base | base_safe)"
			d_conf_ssr[i]="$(echo "${d_conf_ssr[i]}" | awk '{gsub(/obfsparam=[^&]*/, "'obfsparam=${obfsparam_base}'", $0); print $1}')"
		fi

		if [ ! "$remarks" = "" ]; then
			remarks_base="$(echo -n "$remarks" | base64 | no_n_base | base_safe)"
			d_conf_ssr[i]="$(echo "${d_conf_ssr[i]}" | awk '{gsub(/remarks=[^&]*/, "'remarks=${remarks_base}'", $0); print $1}')"
		fi

		e_conf_ssr[i]="$(echo -n "${d_conf_ssr[i]}" | base64 | no_n_base | base_safe)"
		my_sub_ssr[i]="$(echo "ssr://${e_conf_ssr[i]}")"
	done
	
	if [ "$sub_ssr_random_show" -gt 0 ] 2>/dev/null; then
		my_sub_ssr=($(echo "$(shuf -e "${my_sub_ssr[@]}" -n $sub_ssr_random_show)"))
	fi
}

function main(){
	echo $(date) Mission Starting...
	
	ss_ssr
	sub_ssr
	my_ssr_list=($(echo ${my_ssr_dic[*]}))
	all_ssr_list=(${my_ss_ssr[*]} ${my_ssr_list[*]} ${my_sub_ssr[*]})
	subscription_raw="$(echo -n "${all_ssr_list[@]}" | base64 | no_n_base | base_safe)"
	echo "$subscription_raw" >${file}
	
	echo $(date) Mission Accomplished.
}

main
