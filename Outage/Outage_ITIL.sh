#!/bin/sh
#
# Script que Insere Hosts em Outage(Manutencao) de maneira automatica.
#
# 
# Author: Luiz Sales - luiz@lsales.biz
# Blog : www.redhate.me
#


# VARIABLES


#HOSTNAME=''
API='' # http://localhost/api_jsonrpc.php

# CONSTANT VARIABLES
ZABBIX_USER=''
ZABBIX_PASS=''

HOSTNAME=$1
DATETIME_INICIO=$(date -d "$2"  "+%s")
DATETIME_FINAL=$(date -d "$3"  "+%s")
CRQNUMBER=$4
PERIOD=$(expr $DATETIME_FINAL - $DATETIME_INICIO)


help() {
	echo "****************************************"
	echo "**                                    **"
	echo "**             OUTAGE API             **"
	echo "**                                    **"
	echo "****************************************"
	echo
	echo
	echo "$0 HOST 'MM/DD/AAA HH:MM:SS' 'MM/DD/AAA HH:MM:SS' 'NOME DA MANUTENCAO'"
	echo "$0 HOST '07/12/2015 23:00:00' '7/13/2015 2:00:00' 'NOME DA MANUTENCAO'"
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
        \"output\": [
                \"hostid\"
                    ],
        \"filter\": {
                \"host\" : [ \"$HOSTNAME\" ]
                }
          },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}" | awk -v RS='{"' -F: '/^hostid/ {print $2}' | awk -F\" '{print $2}'
}
HOSTID=$(get_host_id);

outage_mk() {

	wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

	\"jsonrpc\": \"2.0\",
    	\"method\": \"maintenance.create\",
    	\"params\": {
        	\"name\": \"$CRQNUMBER\",
        	\"active_since\": \"$DATETIME_INICIO\",
        	\"active_till\": \"$DATETIME_FINAL\",
        	\"hostids\": [
            		\"$HOSTID\"
        		],
        \"timeperiods\": [
            {
                \"timeperiod_type\": \"0\",
                \"every\": \"1\",
                \"dayofweek\": \"64\",
                \"start_time\": \"$DATETIME_INICIO\",
                \"period\": \"$PERIOD\"
            }
        ]
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1 }"
}

outage_get() {

	wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

	\"jsonrpc\": \"2.0\",
    	\"method\": \"maintenance.get\",
   	\"params\": {
        	\"output\": \"extend\",
        	\"selectHosts\": \"extend\",
		\"selectGroups\": \"extend\",
        	\"selectTimeperiods\": \"extend\"
    	},
    	\"auth\": \"$AUTH_TOKEN\",
    	\"id\": 1 }" 
}

if [ -z $1 ]; then
	echo
	help;
	else
	echo
	outage_mk;
	echo
fi

