#!/bin/sh
#
# Script que Inclui intervalos de manutenção no Ambiente IT Services(SLA) 
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
	echo "**           SLA IT SERVICES          **"
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

get_itservices() {

  	wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{
	
	\"jsonrpc\": \"2.0\",
	\"method\": \"service.get\",
	\"params\": {
		\"output\": \"extend\",
		\"selectDependencies\": \"extend\",
		\"selectParentDependencies\": \"extend\",
	\"filter\" : {
		\"name\" : [ \"$HOSTNAME\" ] }
	},
	\"auth\": \"$AUTH_TOKEN\",
	\"id\": 1}"
}
#get_itservices;

SERVICEID_P=$(get_itservices | awk -v RS='{"' -F: '/^serviceid/ {print $2}' | awk -F\" '{print $2}')
SERVICEID_F=$(get_itservices | awk -v RS=',"' -F: '/^serviceid/ {print $2}' | sed 's/,{"linkid"//g' | sed 's/}//g' | sed 's/]//g' | sed 's/\"//g')
echo $SERVICEID_P > $HOSTNAME.OUT
echo $SERVICEID_F >> $HOSTNAME.OUT


outage_mk_its() {
        wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{
 
	\"jsonrpc\": \"2.0\",
    	\"method\": \"service.addtimes\",
    	\"params\": {
        	\"serviceid\": \"$SERVICEID\",
        	\"type\": \"2\",
        	\"ts_from\": \"$DATETIME_INICIO\",
        	\"ts_to\": \"$DATETIME_FINAL\",
		\"note\": \"$CRQNUMBER\"
    	},
    	\"auth\": \"$AUTH_TOKEN\",
    	\"id\": 1 }"
}


if [ -z $1 ]; then
	echo
	help;
	else
	echo
	for SERVICEID in `cat $HOSTNAME.OUT`
	do
		outage_mk_its;
	done
fi
rm $HOSTNAME.OUT
