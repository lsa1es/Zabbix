#!/bin/sh
#
# Criador de Mapa para Hosts com Items 
# Author: Luiz Sales - luiz@lsales.biz
# Blog : www.redhate.me





#HOSTNAME=''
API='' # http://localhost/api_jsonrpc.php

# CONSTANT VARIABLES
ZABBIX_USER=''
ZABBIX_PASS=''

HOSTNAME=$1

LARGURA="1347"
ALTURA="600"
LARGURA_P=$(expr 1347 / 2)
ALTURA_P=$(expr 600 / 4)
ALTURA_F=$(expr $ALTURA_P \* 3)
RAND_LARG=$((RANDOM%$LARGURA_P+$ALTURA_F))
#echo $RAND_LARG

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

get_items_hosts() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"item.get\",
        \"params\": {
        \"output\": \"extend\",
        \"hostids\" : \"$HOSTID\",
        \"with_triggers\" : \"1\",
        \"selectTriggers\" : \"extend\"
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}"  | awk -v RS=',"' -F: '/^name/ {print $2}'
}
#echo "Todos os Items com Trigger de $2"
ITEMSHOST=$(get_items_hosts)

QNTD_ITEM=$(get_items_hosts | wc -l)

get_item_triggerid() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"item.get\",
        \"params\": {
        \"output\": \"extend\",
        \"hostids\" : \"$HOSTID\",
        \"with_triggers\" : \"1\",
        \"selectTriggers\" : \"extend\",
        \"filter\" : {
                \"name\": [ \"$NOMEITEM\" ] }
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}"  | awk -v RS='{"' -F: '/^triggerid/ {print $2}' | awk -F\" '{print $2}'
}
#get_item_triggerid;
ITEM_TRIGID=$(get_item_triggerid)

seid=2
#echo " "$items | sed s/\"//g

MapMkFilhos() {
        for (( i=1; i<=$QNTD_ITEM; i++, seid=seid+1 ))
        do
		IFS=$'\n'
		for NOMEITEM in "Motor"
		do
#                IFS=$'\n'

		RAND_LARG=$((RANDOM%$LARGURA_P+$ALTURA_F))

                if [ $i -eq $QNTD_ITEM ]; then
                        echo "{"
                        echo -e "\"elementid\":\"$ITEM_TRIGID\","
                        echo -e "\"iconid_off\": \"239\","
                        echo -e "\"icondid_on\": \"240\","
                        echo -e "\"label\":\"$NOMEITEM\","
                        echo -e "\"selementid\":\"$seid\","
                        echo -e "\"elementtype\":\"2\","
                        echo -e "\"x\":\"$RAND_LARG\","
                        echo -e "\"y\":\"$ALTURA_F\""
                        echo "}"
                        break;
                fi
                echo "{"
                echo -e "\"elementid\":\"$ITEM_TRIGID\","
                echo -e "\"iconid_off\":\"239\","
                echo -e "\"iconid_on\" :\"240\","
                echo -e "\"label\":\"$NOMEITEM\","
                echo -e "\"selementid\":\"$seid\","
                echo -e "\"elementtype\":\"2\","
                echo -e "\"x\":\"$RAND_LARG\","
                echo -e "\"y\":\"$ALTURA_F\""
                echo "},"
        	done

	done
break
}

MapMkFilhos
map_mk() {

	wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

	\"jsonrpc\": \"2.0\",
    	\"method\": \"map.create\",
    	\"params\": {
		\"expandproblem\": \"0\",
        	\"name\": \"$HOSTNAME\",
        	\"width\": \"$LARGURA\",
        	\"height\": \"$ALTURA\",
		\"selements\": [
            		{
		\"elementid\": \"$HOSTID\",
		\"x\": \"$LARGURA_P\",
                \"y\": \"$ALTURA_P\",
                \"selementid\": \"1\",
                \"elementtype\": \"0\",
                \"iconid_off\": \"2\"
            		}	
		]
    	},
    	\"auth\": \"$AUTH_TOKEN\",
    	\"id\": 1}"
}
#map_mk
