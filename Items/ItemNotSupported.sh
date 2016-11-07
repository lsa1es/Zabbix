#!/bin/sh
#
# Manage Items Nao Suportados- API ZABBIX
#
# Luiz Sales - luiz@lsales.biz
# redhate.me - lsales.biz
#
# 29/09/15 
#

# VARIABLES



#HOSTNAME=''
API='http://localhost/api_jsonrpc.php'

# CONSTANT VARIABLES
ZABBIX_USER=""
ZABBIX_PASS=""


GH=$2
HOST=$3
 
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

get_hostgroup_id() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"hostgroup.get\",
    \"params\": {
        \"output\": \"extend\",
        \"filter\": {
            \"name\": [
                \"$GH\"
            ]
        }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}"
}
GHID=$(get_hostgroup_id | awk -v RS='{"' -F\" '/^groupid/ {print $3}')


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
G_HID=$(get_host_id | awk -v RS='{"' -F\" '/^hostid/ {print $3}')

get_all_item_ns() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

	\"jsonrpc\": \"2.0\",
    	\"method\": \"item.get\",
    	\"params\": {
        \"output\": [ \"itemid\", 
		      \"name\",
		      \"error\",
		      \"lifetime\" ],
	\"selectItemDiscovery\" : [ \"ts_delete\" ],
	\"filter\": {
		\"state\" : [ \"1\" ] },

        \"sortfield\": \"name\"

    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}"
}

get_all_lld_item_ns() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"item.get\",
        \"params\": {
        \"output\": [ \"itemid\",
                      \"name\",
                      \"error\",
                      \"lifetime\" ],
        \"selectItemDiscovery\" : [ \"ts_delete\" ],
        \"filter\": {
                \"state\" : [ \"1\" ],
                \"flags\":  [ \"4\"] },
        \"sortfield\": \"name\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}"
}


get_host_lld_item_ns() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"item.get\",
        \"params\": {
        \"output\": [ \"itemid\",
                      \"name\",
                      \"error\",
                      \"lifetime\" ],
        \"selectItemDiscovery\" : [ \"ts_delete\" ],
        \"filter\": {
                \"state\" : [ \"1\" ], 
		\"flags\":  [ \"4\"] },
	\"hostids\" : \"$G_HID\",
        \"sortfield\": \"name\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}"
}

get_host_item_ns() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"item.get\",
        \"params\": {
        \"output\": [ \"itemid\",
                      \"name\",
                      \"error\",
                      \"lifetime\" ],
        \"selectItemDiscovery\" : [ \"ts_delete\" ],
        \"filter\": {
                \"state\" : [ \"1\" ] },
        \"hostids\" : \"$G_HID\",
        \"sortfield\": \"name\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}"
}


get_group_lld_item_ns() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"item.get\",
        \"params\": {
        \"output\": [ \"hostid\",
		      \"itemid\",
                      \"name\",
                      \"error\",
                      \"lifetime\" ],
        \"selectItemDiscovery\" : [ \"ts_delete\" ],
        \"filter\": {
                \"state\" : [ \"1\" ],
                \"flags\":  [ \"4\"] },
        \"groupids\" : \"$GHID\",
        \"sortfield\": \"name\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}"
}

get_group_item_ns() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"item.get\",
        \"params\": {
        \"output\": [ \"hostid\",
		      \"itemid\",
                      \"name\",
                      \"error\",
                      \"lifetime\" ],
        \"selectItemDiscovery\" : [ \"ts_delete\" ],
        \"filter\": {
                \"state\" : [ \"1\" ] },
        \"groupids\": \"$GHID\",
        \"sortfield\": \"name\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}"
}

report_insgrp() {
  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"item.get\",
        \"params\": {
        \"output\": [ \"hostid\",
                      \"itemid\",
                      \"name\",
                      \"error\",
                      \"lifetime\" ],
        \"selectItemDiscovery\" : [ \"ts_delete\" ],
        \"filter\": {
                \"state\" : [ \"1\" ] },
        \"groupids\": \"$GHID\",
        \"countOutput\": \"1\",
        \"sortfield\": \"name\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}" | awk -v RS=',"' -F: '/^result/ {print $2}'

} 

help() {
	echo "**********************************************************************************"
        echo
        echo "Menu: "
        echo " "
        echo "gains - Todos os Items Nao Suportados"
        echo "galins - Todos os Items Nao Suportados via LLD"
        echo "ghlins - \$2 Grupo \$3 Host - Todos os Items nao Suportados via LLD de um Host"
        echo "gglins - Todos os Items Nao Suportados via LLD de um Grupo"
        echo "ghins - \$2 Grupo \$3 Host - Todos os Items Nao Suportados de um Host"
        echo "ggins - Todos os Items Nao Suportados de um Grupo"
        echo
        echo
}
case $1 in 
	gains) get_all_item_ns | python -m json.tool
	;;
        galins) get_all_lld_item_ns | python -m json.tool
        ;;
	ghlins) get_host_lld_item_ns | python -m json.tool
	;;
        gglins) get_group_lld_item_ns | python -m json.tool
	;;
	ghins) get_host_item_ns | python -m json.tool
	;;
	ggins) get_group_item_ns |  python -m json.tool
	;;
	qntd_insg) report_insgrp 
	;;
	*) help;
	;;
esac

