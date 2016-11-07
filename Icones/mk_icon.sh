#!/bin/sh

# Script desenvolvido por Luiz Sales para import de icones no zabbix.
# www.lsales.biz - luiz@lsales.biz
#  
#
# Example: ./mk_icon.sh <PREFIXO> <Nome da Imagem.png>
# ./mk_icon.sh WEB www_64.png


API=''


ZABBIX_USER=""
ZABBIX_PASS=""

PRE=$1
FILE=$2
TAM=$(file "$FILE" | awk -F\, '{print $2}' | awk '{print $1}')
ARQ=$(echo $FILE | awk -F\( '{print $1}' | sed 's/.png/_/g' )
BASE64=$(base64 "$FILE")
IMG_NAME="($PRE)_$ARQ($TAM).png"


#echo "$IMG_NAME"
#echo "$BASE64"


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

    wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"image.create\",
    \"params\": {
        \"imagetype\": 1,
        \"name\": \"$IMG_NAME\",
        \"image\": \"$BASE64\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1}"
}



mk_icon

