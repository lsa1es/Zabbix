#!/bin/sh
# Script desenvolvido por Luiz Sales para import de icones no zabbix.
# www.lsales.biz - luiz@lsales.biz
#
#
# Example: ./Mk_Icon_v2.sh <File.zip>
# ./Mk_Icon_v2.sh V2_Icones.zip


API=''
ZABBIX_USER=""
ZABBIX_PASS=""
FILE=$1

ARQ=$(echo $FILE | awk -F\( '{print $1}' | sed 's/.png/_/g' )

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

mk_icon() {
IMG_NAME=$1

    wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"image.create\",
    \"params\": {
        \"imagetype\": \"1\",
        \"name\": \"$IMG_NAME\",
        \"image\": \"$BASE64\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}"
}


FILEok=$(echo $FILE | awk -F".zip" '{print $1}' )
echo $FILEok

unzip -d /tmp/ $FILE | awk -F: '{print $2}' | sed 's/ //g' | grep -v ".zip" > $FILEok.dsc

IFS=$'\n'
for CAMINHO in `cat $FILEok.dsc`
do
	BASE64=$(base64 -w 0 $CAMINHO)
	l=$(echo $CAMINHO | grep -o  "/" | wc -l)
	ln=$(echo $l + 1 | bc)
	IMG_NAME=$(echo $CAMINHO | awk -F"/" '{print $'$ln'}' | cut -d . -f1)
  mk_icon $IMG_NAME $CAMINHO
done
unset $IFS
