#!/bin/bash
MYIP=$(wget -qO- ipinfo.io/ip);
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
UWhite='\033[4;37m'       # White
On_IPurple='\033[0;105m'  #
On_IRed='\033[0;101m'
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
# // Exporting Language to UTF-8

export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'


# // Export Color & Information
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'

domain=$(cat /etc/xray/domain)
tls="$(cat ~/log-install.txt | grep -w "Vless TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "Vless None TLS" | cut -d: -f2|sed 's/ //g')"
user=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=1
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
uuid=$(cat /proc/sys/kernel/random/uuid)
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                 ${BIWhite}${UWhite}VLESS TRIAL ACCOUNT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "   Generat user for 1 day ....."
sleep 3
sed -i '/#vless$/a\#& '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\#& '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
vlesslink1="vless://${uuid}@${domain}:443?security=tls&encryption=none&type=ws&headerType=none&path=/vless&sni=${domain}&host=${domain}#VLESS-TLS-${user}"
#vlesslink1="vless://${uuid}@${domain}:443?path=/vless&security=tls&encryption=none&type=ws#${user}"
#vlesslink2="vless://${uuid}@${domain}:80?path=/vless&encryption=none&type=ws#${user}"
vlesslink2="vless://${uuid}@${domain}:80?security=none&encryption=none&type=ws&host=${domain}&path=vless#VLESS-MX-${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=bug.com#${user}"
systemctl restart xray
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}VLESS ACCOUNT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Remarks       :${NC} ${BIWhite}${user}${NC}"
echo -e "  ${BICyan} Host/IP       :${NC} ${BIWhite}${domain}${NC}"
echo -e "  ${BICyan} Port TLS      :${NC} ${BIWhite}443${NC}"
echo -e "  ${BICyan} Port None TLS :${NC} ${BIWhite}80${NC}"
echo -e "  ${BICyan} Port GRPC     :${NC} ${BIWhite}443${NC}"
echo -e "  ${BICyan} ID            :${NC} ${BIWhite}${uuid}${NC}"
echo -e "  ${BICyan} Encryption    :${NC} ${BIWhite}none${NC}"
echo -e "  ${BICyan} Network       :${NC} ${BIWhite}WS${NC}"
echo -e "  ${BICyan} Path          :${NC} ${BIWhite}/vless${NC}"
echo -e "  ${BICyan} ServiceName   :${NC} ${BIWhite}vless-grpc${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} 
┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Link TLS     :${NC}"
echo -e "  ${BIWhite} ${vlesslink1}${NC}"
echo ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} 
┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Link None TLS:${NC}"
echo -e "  ${BIWhite} ${vlesslink2}${NC}"
echo ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Link GRPC    :${NC}"
echo -e "  ${BIWhite} ${vlesslink3}${NC}"
echo ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Expired On   :${NC} ${BIWhite}$exp${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"

menu-vless
