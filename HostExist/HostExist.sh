#!/bin/sh
#
# Script faz o check se o host existe ou nao no Zabbix - API ZABBIX
#
# Luiz Sales - luiz@lsales.biz
# redhate.me - lsales.biz
#
# 14/10/15
#


API='http://localhost/api_jsonrpc.php'

# CONSTANT VARIABLES
ZABBIX_USER=""
ZABBIX_PASS=""

NAME=$1
help()	{
	echo
	echo "$0 <host>"
	echo
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
        \"output\": \"extend\",
          \"filter\": {
            \"host\" : [ \"$NAME\" ] }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 2 }"
}
get_name_id() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {
        \"output\": \"extend\",
          \"filter\": {
            \"name\" : [ \"$NAME\" ] }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 2 }"
}

HOSTID=$(get_host_id | awk -v RS='{"' -F\" '/^hostid/ {print $3}')
NAMEID=$(get_name_id | awk -v RS='{"' -F\" '/^hostid/ {print $3}')

if [ -z $HOSTID ] && [ -z $NAMEID ];then
	echo "Host: $1 Nao Existe no Zabbix"
	else
	echo "Host: $1 Existe"
fi

