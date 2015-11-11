#!/bin/sh

# Script que adiciona o Template ao Host - API ZABBIX

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
            \"name\"
        ],
        \"filter\": {
            \"name\" : [ \"$HOST\" ] }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 2 }"
}
HOSTID=$(get_host_id | awk -v RS='{"' -F\" '/^hostid/ {print $3}')

get_template_id() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

    \"jsonrpc\": \"2.0\",
    \"method\": \"template.get\",
    \"params\": {
        \"output\": \"templateid\",
        \"filter\": {
            \"host\": [
                \"$TEMPLATE\"
         	]
        }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1 }"
}
TEMPLATEID=$(get_template_id | awk -v RS='{"' -F\" '/^templateid/ {print $3}')


add_template_to_host() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

    \"jsonrpc\": \"2.0\",
    \"method\": \"template.massadd\",
    \"params\": {
        \"templates\": [
            {
                \"templateid\": \"$TEMPLATEID\"
            }
        ],
        \"hosts\": [
            {
                \"hostid\": \"$HOSTID\"
            }
       ]
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1 }"
}

help() {
	echo "*******************************"
	echo
	echo "$0 <Host> <template name>"
	echo
	echo "*******************************"
	echo
}

if [ -z $1 ]; then
	help;
	else
	add_template_to_host;
fi


