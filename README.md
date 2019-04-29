### Some scripts collection  for Debian 9 64
```bash
apt update && apt install curl vim wget -y
```  
---  
#### security ssh  
`curl https://raw.githubusercontent.com/mixool/script/debian-9/securityssh.sh | bash`  
#### 联通APP签到
`bash <(curl -s https://raw.githubusercontent.com/mixool/script/debian-9/daySign_LT.sh) ${username} ${password}`
