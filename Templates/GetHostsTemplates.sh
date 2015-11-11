#!/bin/sh

# Script que mostra os Templates que cada host contem - API ZABBIX

# Luiz Sales - luiz@lsales.biz
# redhate.me - lsales.biz

API='http://localhost/api_jsonrpc.php'

# CONSTANT VARIABLES
ZABBIX_USER=""
ZABBIX_PASS=""

HOST=$1
TEMPLATE=$2

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
            \"host\" : [ \"$HOST\" ] }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 2 }"
}
HOSTID=$(get_host_id | awk -v RS='{"' -F\" '/^hostid/ {print $3}')


gettemplateofhost() {

	    wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{
	
	\"jsonrpc\": \"2.0\",
    	\"method\": \"host.get\",
    	\"params\": {
        	\"output\": [\"$hostid\"],
        	\"selectParentTemplates\": [
            	\"name\"
        	],
        \"hostids\": \"$HOSTID\"
    },
    \"id\": 1,
    \"auth\": \"$AUTH_TOKEN\" }"
}
TEMPLATES=$(gettemplateofhost | awk -v RS='{"' -F\" '/^name/ {printf $3","}')
echo "HOST $HOST - TEMPLATES: $TEMPLATES"

