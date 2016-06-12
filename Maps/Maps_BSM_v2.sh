#!/bin/sh
#
# Criador de Mapa para Hosts com Items
# Author: Luiz Sales - luiz@lsales.biz
# Blog : www.redhate.me
#
# Use: $0 <host> <nome do mapa>
#
# So funciona com items sem espaço e até 6 items por host. Ainda estou melhorando... 
# OBS: Se voce for copiar, favor colocar o link para o codigo original e nao apenas mencionar uma ideia.
#





#HOSTNAME=''
API='' # http://localhost/api_jsonrpc.php

# CONSTANT VARIABLES
ZABBIX_USER=''
ZABBIX_PASS=''

HOSTNAME=$1
NOME=$2

LARGURA="1347"
ALTURA="600"
LARGURA_P=$(expr 1347 / 2)
ALTURA_P=$(expr 600 / 4)
ALTURA_F=$(expr $ALTURA_P \* 3)
RAND_LARG=$((RANDOM%$LARGURA_P+$ALTURA_F))
LARGURA_I="29"
#echo $RAND_LARG
#RAND_LABEL_LOCATION=$(shuf -e "0" "1" "2" "3")

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
AUTH=$(authenticate)

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
        \"auth\": \"$AUTH\",
        \"id\": 1}" | awk -v RS='{"' -F: '/^hostid/ {print $2}' | awk -F\" '{print $2}'
}
HOSTID=$(get_host_id)
get_item_ids() {
 wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

    \"jsonrpc\": \"2.0\",
    \"method\": \"item.get\",
    \"params\": {
        \"output\": \"extend\",
        \"hostids\": \"$HOSTID\",
        \"sortfield\": \"name\"
    },
    \"auth\": \"$AUTH\",
   \"id\": 1}"
}
mkfilhos() {
seid=2
GIDS=$(get_item_ids |  sed 's/},{/} {/g')
QNTD_GIDS=$(get_item_ids | python -m json.tool | grep itemid | wc -l)
QNTD_GIDSL=`expr $QNTD_GIDS + 1`
for ITEM in `echo $GIDS`
do
        # Loop random label location - begin
#       LABEL_LOCATION=("0" "1" "2" "3")
#       RANDOM=$$$(date +%s)
#       RAND_LABEL_LOCATION=${LABEL_LOCATION[$RANDOM % ${#LABEL_LOCATION[@]} ]}
        # loop random label location - end

        RAND_LABEL_LOCATION=$(shuf -e "0" "1" "2" "3" | head -n1)

        ALTURA_F=$(expr $ALTURA_P \* 3)
        RAND_LARG=$((RANDOM%$LARGURA_P+$ALTURA_F))
        ITEMID=`echo $ITEM | awk -v RS='{"' -F: '/^itemid/ {print $2}' | awk -F\" '{print $2}'`
        NAME=`echo $ITEM | awk -v RS=',"' -F: '/^name/ {print $2}' | awk -F\" '{print $2}'`
        UNITS=`echo $ITEM | awk -v RS=',"' -F: '/^units/ {print $2}' | awk -F\" '{print $2}'`
        KEY=`echo $ITEM | awk -v RS=',"' -F: '/^key_/ {print $2}' | awk -F\" '{print $2}'`
        if [ "$QNTD_GIDSL" -ne "$seid" ]; then
        echo -e "\t{"
        echo -e "\t\"selementid\": \"$seid\","
        echo -e "\t\"label_location\": \"$RAND_LABEL_LOCATION\","
        echo -e "\t\"x\": \"$LARGURA_I\","
        echo -e "\t\"y\": \"$ALTURA_F\","
        echo -e "\t\"elementid\": \"$HOSTID\","
        echo -e "\t\"label\" : \"$NAME: {$HOSTNAME:$KEY.last()}\","
        echo -e "\t\"elementtype\": 4,"
        echo -e "\t\"iconid_off\": \"151\""
        echo -e "\t},"
        seid=`expr $seid + 1`
        LARGURA_I=`expr $LARGURA_I + 200`
                else
        echo -e "\t{"
        echo -e "\t\"selementid\": \"$seid\","
        echo -e "\t\"label_location\": \"$RAND_LABEL_LOCATION\","
        echo -e "\t\"x\": \"$LARGURA_I\","
        echo -e "\t\"y\": \"$ALTURA_F\","
        echo -e "\t\"elementid\": \"$HOSTID\","
        echo -e "\t\"label\": \"$NAME: {$HOSTNAME:$KEY.last()}\","
        echo -e "\t\"elementtype\": 4,"
        echo -e "\t\"iconid_off\": \"151\""
        echo -e "\t}"
        fi


done
}
mklinks() {
echo "\"links\": ["
seid=2
GIDS=$(get_item_ids |  sed 's/},{/} {/g')
QNTD_GIDS=$(get_item_ids | python -m json.tool | grep itemid | wc -l)
QNTD_GIDSL=`expr $QNTD_GIDS + 1`
for ITEM in `echo $GIDS`
do
        if [ "$QNTD_GIDSL" -ne "$seid" ]; then
        echo -e "\t{"
        echo -e "\t\"color\" : \"009900\","
        echo -e "\t\"drawtype\" : \"2\","
        echo -e "\t\"selementid1\": \"1\","
        echo -e "\t\"selementid2\": \"$seid\""
        echo -e "\t},"
        seid=`expr $seid + 1`
                else
        echo -e "\t{"
        echo -e "\t\"color\" : \"009900\","
        echo -e "\t\"drawtype\" : \"2\","
        echo -e "\t\"selementid1\": \"1\","
        echo -e "\t\"selementid2\": \"$seid\""
        echo -e "\t}"
        echo    "]"
        fi
done

}


start() {
 wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

    \"jsonrpc\": \"2.0\",
    \"method\": \"map.create\",
    \"params\": {
        \"name\": \"$NOME\",
        \"width\": $LARGURA,
        \"height\": $ALTURA,
        \"label_type\": \"0\",
        \"expand_macros\": \"1\",
        \"selements\": [
                {
                \"selementid\": \"1\",
                \"x\": \"$LARGURA_P\",
                \"y\": \"$ALTURA_P\",
                \"label\": \"{HOST.NAME}\",
                \"elementid\": \"$HOSTID\",
                \"elementtype\": 0,
                \"iconid_off\": \"151\"
                },
                $(mkfilhos)
                ],
                $(mklinks)
        },
    \"auth\": \"$AUTH\",
    \"id\": 1}"
}
start
#mkfilhos

