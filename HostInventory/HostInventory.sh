#!/bin/sh
#
# Update Host Invetory - API ZABBIX
#
# Luiz Sales - luiz@lsales.biz
# redhate.me - lsales.biz
#
# 10/09/15 
#

# VARIABLES



#HOSTNAME=''
API='http://localhost/api_jsonrpc.php'

# CONSTANT VARIABLES
ZABBIX_USER=""
ZABBIX_PASS=""

HOST=$1
INV_MODE=$2

help()	{
	echo
	echo "$0 <HOSTNAME> <INVENTORY_MODE>"
	echo
	echo "-1 - disabled;"
	echo "0  - (default) manual;"
	echo "1  - automatic."
	echo
}
 
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
            \"hostid\",
            \"host\"
        ],
        \"filter\": {
            \"name\" : [ \"$HOST\" ] }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 2 }"
}
HOSTID=$(get_host_id | awk -v RS='{"' -F\" '/^hostid/ {print $3}')

add_inventory_auto_to_host() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

    \"jsonrpc\": \"2.0\",
    \"method\": \"host.massupdate\",
    \"params\": {
	\"inventory_mode\": \"$INV_MODE\",
	\"hosts\": [
            {
                \"hostid\": \"$HOSTID\"
            }
       ]
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1 }"
}
if [ -z $1 ]; then
	help;
	else
	add_inventory_auto_to_host;
fi



