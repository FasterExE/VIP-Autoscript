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

apt install python2 -y; cp /usr/bin/python2 /usr/bin/python; systemctl restart WebSocket WebSocket.SSH WebSocket.OVPN stunnel4
date
domain=$(cat /etc/xray/domain)
mkdir -p /etc/xray 
apt install iptables iptables-persistent -y
ntpdate pool.ntp.org 
timedatectl set-ntp true
systemctl enable chronyd
systemctl restart chronyd
systemctl enable chrony
systemctl restart chrony
timedatectl set-timezone Asia/Jakarta
chronyc sourcestats -v
chronyc tracking -v
apt clean all && apt update
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion ntpdate -y
ntpdate pool.ntp.org
apt -y install chrony
apt install zip -y
apt install curl pwgen openssl netcat cron -y


# install xray
sleep 1
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan}Downloading & Installing xray core${NC}${BIYellow} ★ ${NC}"*
domainSock_dir="/run/xray";! [ -d $domainSock_dir ] && mkdir  $domainSock_dir
chown www-data.www-data $domainSock_dir
# Make Folder XRay
mkdir -p /var/log/xray
mkdir -p /etc/xray
chown www-data.www-data /var/log/xray
chmod +x /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /var/log/xray/access2.log
touch /var/log/xray/error2.log
# / / Ambil Xray Core Version Terbaru
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version 1.5.6



## crt xray
systemctl stop nginx
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

# nginx renew ssl
echo -n '#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/etc/init.d/nginx start
/etc/init.d/nginx status
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root;then (crontab -l;echo "15 03 */3 * * /usr/local/bin/ssl_renew.sh") | crontab;fi

mkdir -p /home/vps/public_html

# set uuid
uuid=$(cat /proc/sys/kernel/random/uuid)
# xray config
cat > /etc/xray/config.json << END
{
  "log" : {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
      {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
   {
     "listen": "127.0.0.1",
     "port": "14016",
     "protocol": "vless",
      "settings": {
          "decryption":"none",
            "clients": [
               {
                 "id": "${uuid}"                 
#vless
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": {
                "path": "/vless"
          }
        }
     },
     {
     "listen": "127.0.0.1",
     "port": "23456",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "${uuid}",
                 "alterId": 0
#vmess
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": {
                "path": "/vmess"
          }
        }
     },
    {
      "listen": "127.0.0.1",
      "port": "25432",
      "protocol": "trojan",
      "settings": {
          "decryption":"none",		
           "clients": [
              {
                 "password": "${uuid}"
#trojanws
              }
          ],
         "udp": true
       },
       "streamSettings":{
           "network": "ws",
           "wsSettings": {
               "path": "/trojan-ws"
            }
         }
     },
    {
         "listen": "127.0.0.1",
        "port": "30300",
        "protocol": "shadowsocks",
        "settings": {
           "clients": [
           {
           "method": "aes-128-gcm",
          "password": "${uuid}"
#ssws
           }
          ],
          "network": "tcp,udp"
       },
       "streamSettings":{
          "network": "ws",
             "wsSettings": {
               "path": "/ss-ws"
           }
        }
     },	
      {
        "listen": "127.0.0.1",
     "port": "24456",
        "protocol": "vless",
        "settings": {
         "decryption":"none",
           "clients": [
             {
               "id": "${uuid}"
#vlessgrpc
             }
          ]
       },
          "streamSettings":{
             "network": "grpc",
             "grpcSettings": {
                "serviceName": "vless-grpc"
           }
        }
     },
     {
      "listen": "127.0.0.1",
     "port": "31234",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "${uuid}",
                 "alterId": 0
#vmessgrpc
             }
          ]
       },
       "streamSettings":{
         "network": "grpc",
            "grpcSettings": {
                "serviceName": "vmess-grpc"
          }
        }
     },
     {
        "listen": "127.0.0.1",
     "port": "33456",
        "protocol": "trojan",
        "settings": {
          "decryption":"none",
             "clients": [
               {
                 "password": "${uuid}"
#trojangrpc
               }
           ]
        },
         "streamSettings":{
         "network": "grpc",
           "grpcSettings": {
               "serviceName": "trojan-grpc"
         }
      }
   },
   {
    "listen": "127.0.0.1",
    "port": "30310",
    "protocol": "shadowsocks",
    "settings": {
        "clients": [
          {
             "method": "aes-128-gcm",
             "password": "${uuid}"
#ssgrpc
           }
         ],
           "network": "tcp,udp"
      },
    "streamSettings":{
     "network": "grpc",
        "grpcSettings": {
           "serviceName": "ss-grpc"
          }
       }
    }	
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink" : true,
      "statsOutboundDownlink" : true
    }
  }
}
END
rm -rf /etc/systemd/system/xray.service.d
rm -rf /etc/systemd/system/xray@.service
cat <<EOF> /etc/systemd/system/xray.service
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

EOF
cat > /etc/systemd/system/runn.service <<EOF
[Unit]
Description=Mantap-Sayang
After=network.target

[Service]
Type=simple
ExecStartPre=-/usr/bin/mkdir -p /var/run/xray
ExecStart=/usr/bin/chown www-data:www-data /var/run/xray
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Install Trojan Go
latest_version="$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases" | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
trojango_link="https://github.com/p4gefau1t/trojan-go/releases/download/v${latest_version}/trojan-go-linux-amd64.zip"
mkdir -p "/usr/bin/trojan-go"
mkdir -p "/etc/trojan-go"
cd `mktemp -d`
curl -sL "${trojango_link}" -o trojan-go.zip
unzip -q trojan-go.zip && rm -rf trojan-go.zip
mv trojan-go /usr/local/bin/trojan-go
chmod +x /usr/local/bin/trojan-go
mkdir /var/log/trojan-go/
touch /etc/trojan-go/akun.conf
touch /var/log/trojan-go/trojan-go.log

# Buat Config Trojan Go
cat > /etc/trojan-go/config.json << END
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 2087,
  "remote_addr": "127.0.0.1",
  "remote_port": 89,
  "log_level": 1,
  "log_file": "/var/log/trojan-go/trojan-go.log",
  "password": [
      "$uuid"
  ],
  "disable_http_check": true,
  "udp_timeout": 60,
  "ssl": {
    "verify": false,
    "verify_hostname": false,
    "cert": "/etc/xray/xray.crt",
    "key": "/etc/xray/xray.key",
    "key_password": "",
    "cipher": "",
    "curves": "",
    "prefer_server_cipher": false,
    "sni": "$domain",
    "alpn": [
      "http/1.1"
    ],
    "session_ticket": true,
    "reuse_session": true,
    "plain_http_response": "",
    "fallback_addr": "127.0.0.1",
    "fallback_port": 0,
    "fingerprint": "firefox"
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "prefer_ipv4": true
  },
  "mux": {
    "enabled": false,
    "concurrency": 8,
    "idle_timeout": 60
  },
  "websocket": {
    "enabled": true,
    "path": "/trojango",
    "host": "$domain"
  },
    "api": {
    "enabled": false,
    "api_addr": "",
    "api_port": 0,
    "ssl": {
      "enabled": false,
      "key": "",
      "cert": "",
      "verify_client": false,
      "client_cert": []
    }
  }
}
END

# Installing Trojan Go Service
cat > /etc/systemd/system/trojan-go.service << END
[Unit]
Description=Trojan-Go Service Mod By ARTA M
Documentation=github.com/adammoi/vipies
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
END

# Trojan Go Uuid
cat > /etc/trojan-go/uuid.txt << END
$uuid
END

#nginx config
cat > /etc/nginx/conf.d/protocol.conf <<EOF
    server {
             listen 80;
             listen [::]:80;
             listen 8080;
             listen [::]:8080;
             listen 443 ssl http2 reuseport;
             listen [::]:443 http2 reuseport;	
             server_name $domain;
             ssl_certificate /etc/xray/xray.crt;
             ssl_certificate_key /etc/xray/xray.key;
             ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
             ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
             root /home/vps/public_html;
        }
EOF
sed -i '$ ilocation = /vless' /etc/nginx/conf.d/protocol.conf
sed -i '$ i{' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_pass http://127.0.0.1:14016;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/protocol.conf
sed -i '$ i}' /etc/nginx/conf.d/protocol.conf

sed -i '$ ilocation = /vmess' /etc/nginx/conf.d/protocol.conf
sed -i '$ i{' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_pass http://127.0.0.1:23456;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/protocol.conf
sed -i '$ i}' /etc/nginx/conf.d/protocol.conf

sed -i '$ ilocation = /trojan-ws' /etc/nginx/conf.d/protocol.conf
sed -i '$ i{' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_pass http://127.0.0.1:25432;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/protocol.conf
sed -i '$ i}' /etc/nginx/conf.d/protocol.conf

sed -i '$ ilocation = /trojango' /etc/nginx/conf.d/protocol.conf
sed -i '$ i{' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_pass http://127.0.0.1:2087;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/protocol.conf
sed -i '$ i}' /etc/nginx/conf.d/protocol.conf

sed -i '$ ilocation = /ss-ws' /etc/nginx/conf.d/protocol.conf
sed -i '$ i{' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_pass http://127.0.0.1:30300;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/protocol.conf
sed -i '$ i}' /etc/nginx/conf.d/protocol.conf

sed -i '$ ilocation /' /etc/nginx/conf.d/protocol.conf
sed -i '$ i{' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_pass http://127.0.0.1:700;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/protocol.conf
sed -i '$ i}' /etc/nginx/conf.d/protocol.conf

sed -i '$ ilocation ^~ /vless-grpc' /etc/nginx/conf.d/protocol.conf
sed -i '$ i{' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:24456;' /etc/nginx/conf.d/protocol.conf
sed -i '$ i}' /etc/nginx/conf.d/protocol.conf

sed -i '$ ilocation ^~ /vmess-grpc' /etc/nginx/conf.d/protocol.conf
sed -i '$ i{' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:31234;' /etc/nginx/conf.d/protocol.conf
sed -i '$ i}' /etc/nginx/conf.d/protocol.conf

sed -i '$ ilocation ^~ /trojan-grpc' /etc/nginx/conf.d/protocol.conf
sed -i '$ i{' /etc/nginx/conf.d/protocol.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/protocol.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:33456;' /etc/nginx/conf.d/protocol.conf
sed -i '$ i}' /etc/nginx/conf.d/protocol.conf

cat > /etc/nginx/conf.d/web.conf << END
server {
    listen 89 ssl;
    server_name $domain;

    ssl_certificate /etc/xray/xray.crt;
    ssl_certificate_key /etc/xray/xray.key;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128+AESGCM:EECDH+AES128+AESGCM;
    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;

    location / {
        root   /var/www/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
END

wget -O /var/www/html/index.html https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/index.html


echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan}Enable & restart xray${NC}${BIYellow} ★ ${NC}"
systemctl daemon-reload
systemctl daemon-reload
systemctl enable xray
systemctl restart xray
systemctl restart nginx
systemctl enable runn
systemctl restart runn
systemctl stop trojan-go
systemctl start trojan-go
systemctl enable trojan-go
systemctl restart trojan-go

cd /usr/bin/
# vmess
wget -O add-ws "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/add-ws.sh" && chmod +x add-ws
wget -O trialvmess "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/trialvmess.sh" && chmod +x trialvmess
wget -O renew-ws "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/renew-ws.sh" && chmod +x renew-ws
wget -O del-ws "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/del-ws.sh" && chmod +x del-ws
wget -O cek-ws "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/cek-ws.sh" && chmod +x cek-ws

# vless
wget -O add-vless "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/add-vless.sh" && chmod +x add-vless
wget -O trialvless "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/trialvless.sh" && chmod +x trialvless
wget -O renew-vless "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/renew-vless.sh" && chmod +x renew-vless
wget -O del-vless "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/del-vless.sh" && chmod +x del-vless
wget -O cek-vless "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/cek-vless.sh" && chmod +x cek-vless

# trojan
wget -O add-tr "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/add-tr.sh" && chmod +x add-tr
wget -O trialtrojan "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/trialtrojan.sh" && chmod +x trialtrojan
wget -O del-tr "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/del-tr.sh" && chmod +x del-tr
wget -O renew-tr "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/renew-tr.sh" && chmod +x renew-tr
wget -O cek-tr "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/cek-tr.sh" && chmod +x cek-tr

# trojan go
wget -O addtrgo "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/addtrgo.sh" && chmod +x addtrgo
wget -O trialtrojango "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/trialtrojango.sh" && chmod +x trialtrojango
wget -O deltrgo "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/deltrgo.sh" && chmod +x deltrgo
wget -O renewtrgo "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/renewtrgo.sh" && chmod +x renewtrgo
wget -O cektrgo "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/cektrgo.sh" && chmod +x cektrgo


sleep 1
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
yellow "xray/Vmess"
yellow "xray/Vless"

mv /root/domain /etc/xray/ 
if [ -f /root/scdomain ];then
rm /root/scdomain > /dev/null 2>&1
fi
clear
rm -f ins-xray.sh  
