#!/bin/sh
#
# Script para pegar o erro dos Agents via Host e Grupo de Host - API ZABBIX
#
# Luiz Sales - luiz@lsales.biz
# redhate.me - lsales.biz
#
# 07/10/15
#

# VARIABLES



#HOSTNAME=''
API='http://localhost/api_jsonrpc.php'

# CONSTANT VARIABLES
ZABBIX_USER=""
ZABBIX_PASS=""

NAME=$2

help()	{
	echo
	echo "$0 host <HOSTNAME>"
	echo "$0 grp <Grupo> "
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
            \"name\" : [ \"$NAME\" ] }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 2 }"
}
HOSTID=$(get_host_id | awk -v RS='{"' -F\" '/^hostid/ {print $3}')

get_hostgroup_id() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"hostgroup.get\",
    \"params\": {
        \"output\": \"extend\",
        \"filter\": {
            \"name\": [
                \"$NAME\"
            ]
        }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}"
}
GROUPID=$(get_hostgroup_id | awk -v RS='{"' -F\" '/^groupid/ {print $3}')



host_get_error() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {
	\"hostids\" : \"$HOSTID\",
        \"output\": [
		\"host\",
		\"name\",
		\"error\" ],
          \"filter\": {
		\"available\" : \"2\" }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 2 }"
} 


group_get_error() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {
        \"groupids\" : \"$GROUPID\",
        \"output\": [
                \"host\",
                \"name\",
                \"error\" ],
          \"filter\": {
                \"available\" : \"2\" }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 2 }"
}

case $1 in 
	host) host_get_error | python -m json.tool
	;;
	grp) group_get_error | python -m json.tool
	;;
	ts) group_get_error
	;;
	*) help
	;;
esac
