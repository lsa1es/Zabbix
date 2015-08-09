#!/bin/sh

# VARIABLES


#HOSTNAME=''
SERVER='zbx.lsales.bix'
IP=''
API='' # http://localhost/api_jsonrpc.php
# CONSTANT VARIABLES
ERROR='0'
ZABBIX_USER=""
ZABBIX_PASS=""
PROXYNAME=$1
HOSTNAME=$2
authenticate()
{
    wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"user.login\",
        \"params\": {
                \"user\": \"$ZABBIX_USER\",
                \"password\": \"$ZABBIX_PASS\"},
        \"id\": 0}" | cut -d'"' -f8
}
AUTH_TOKEN=$(authenticate)


get_host_id() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"host.get\",
        \"params\": {
                \"output\": [
                        \"hostid\"
                        ],
                \"filter\": {
                        \"host\" : [ \"$HOSTNAME\" ]
                        }
                },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 0}" | cut -d ":" -f4 | sed s/\}]//g | sed s/\"//g | sed s/,id//g

#| awk -v RS=',"' -F: '/^hostid/ {print $2}'
}

get_proxy_list() {

wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

    \"jsonrpc\": \"2.0\",
    \"method\": \"proxy.get\",
    \"params\": {
        \"output\": \"extend\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1 }" | awk -v RS=',"' -F: '/^host/ {print $2}' 
}

get_proxy_id() {

wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

    \"jsonrpc\": \"2.0\",
    \"method\": \"proxy.get\",
    \"params\": {
        \"output\": [ \"proxyid\" ],
	\"filter\": { \"host\" : [ \"$PROXYNAME\" ] } 
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}" | cut -d ":" -f4 | sed 's/\}],//g' | awk -F \" '{print $2}' 
}
PROXYID=$(get_proxy_id)

get_hosts_proxy() {

wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

    \"jsonrpc\": \"2.0\",
    \"method\": \"proxy.get\",
    \"params\": {
        \"output\": \"extend\",
        \"selectHosts\" : \"name\",
	\"filter\" : { \"proxy_hostid\" : [ \"$PROXYID\" ] }    

	},
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}" 
}

get_hosts_proxy;
