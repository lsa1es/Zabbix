#!/bin/sh

# VARIABLES


#HOSTNAME=''
SERVER='zbx.lsales.bix'
IP=''
API='http://zbx.lsales.biz/api_jsonrpc.php'

# CONSTANT VARIABLES
ERROR='0'
ZABBIX_USER="redhate"
ZABBIX_PASS="r1ed98hat2e"
HOSTGROUP=$1
HOSTN=$2
NOMEITEM=$3
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


get_hostgroups() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{
	 
	\"jsonrpc\": \"2.0\",
	\"method\": \"hostgroup.get\",
	\"params\": {
	\"output\": \"extend\"
        	},
	\"auth\": \"$AUTH_TOKEN\",
	\"id\": 1}" | awk -v RS=',"' -F: '/^name/ {print $2}' | sed 's/\"//g'
}
#echo "Todos os Grupos"
#get_hostgroups;

get_hostgroups_id() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"hostgroup.get\",
        \"params\": {
        \"output\": \"extend\",
	\"filter\": {
		\"name\" : [ \"$HOSTGROUP\" ]
		}
	},
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}" | awk -v RS='{"' -F: '/^groupid/ {print $2}' | awk -F\" '{print $2}'
}
#echo "Group ID de $1"
#get_hostgroups_id;

GRPID=$(get_hostgroups_id)

get_hosts_hostgroups() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"host.get\",
        \"params\": {
        \"output\": \"extend\",
	\"groupids\" : \"$GRPID\"
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}"  | awk -v RS=',"' -F: '/^host/ {print $2}'
}
#echo "Hosts do Grupo $1"
get_hosts_hostgroups;

get_host_id() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"host.get\",
        \"params\": {
        \"output\": [
	        \"hostid\"
                    ],
        \"filter\": {
       		\"host\" : [ \"$HOSTN\" ]
              	}
          },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}" | awk -v RS='{"' -F: '/^hostid/ {print $2}' | awk -F\" '{print $2}'
}
#echo "HostID de $2"
#get_host_id;
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
        \"id\": 1}"  #| awk -v RS=',"' -F: '/^name/ {print $2}'
}
#echo "Todos os Items com Trigger de $2"
#get_items_hosts;


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

get_triggers_hosts() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"trigger.get\",
        \"params\": {
        \"output\": \"extend\",
        \"hostids\" : \"$HOSTID\",
        \"expandComment\" : \"1\",
	\"expandDescription\" : \"1\",
	\"expandExpression\" : \"1\"
	},
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}"  #| awk -v RS=',"' -F: '/^name/ {print $2}'
}
#echo "Todos as triggers do host $2"
#get_triggers_hosts;

mk_father_itservices() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"service.create\",
        \"params\": {
		\"name\" : \"$HOSTGROUP\",
		\"algorithm\" : \"1\",
		\"showsla\" : \"1\",
		\"goodsla\" : \"99.99\",
		\"sortorder\" : \"1\"
	},
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}"  #| awk -v RS=',"' -F: '/^name/ {print $2}'
}
#echo "Criando Pai: $1"
#mk_father_itservices;

get_itservices() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

	\"jsonrpc\": \"2.0\",
	\"method\": \"service.get\",
	\"params\": {
		\"output\": \"extend\",
		\"selectParent\" : \"extend\",
		\"selectTrigger\": \"extend\"
	},
	\"auth\": \"$AUTH_TOKEN\",
	\"id\": 1}"
}
#get_itservices;

get_its_pid() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"service.get\",
        \"params\": {
                \"output\": \"extend\",
                \"selectParent\" : \"extend\",
                \"selectTrigger\": \"extend\",
	        \"expandExpression\" : \"1\",
		\"filter\" : {
			\"name\" : [ \"$HOSTGROUP\" ] }
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}" 
}
#get_its_pid;
ITS_PID=$(get_its_pid | awk -v RS='{"' -F: '/^serviceid/ {print $2}' | awk -F\" '{print $2}' | head -n 1)

mk_child_itservices() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"service.create\",
        \"params\": {
                \"name\" : \"$HOSTN\",
                \"algorithm\" : \"1\",
                \"showsla\" : \"1\",
                \"goodsla\" : \"99.99\",
                \"sortorder\" : \"1\",
		\"parentid\": \"$ITS_PID\"
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}"  #| awk -v RS=',"' -F: '/^name/ {print $2}'
}
#echo "Criando Filho  $2 de Pai $1"
#mk_child_itservices;

get_its_pid_child() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"service.get\",
        \"params\": {
                \"output\": \"extend\",
                \"selectParent\" : \"extend\",
                \"selectTrigger\": \"extend\",
                \"expandExpression\" : \"1\",
                \"filter\" : {
                        \"name\" : [ \"$HOSTN\" ] }
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}"
}
#get_its_pid;
ITS_PID_CHILD=$(get_its_pid_child | awk -v RS='{"' -F: '/^serviceid/ {print $2}' | awk -F\" '{print $2}' | head -n 1)


mk_child_its_trigger() {

  wget -O- -o /dev/null $API --header 'Content-Type: application/json-rpc' --post-data "{

        \"jsonrpc\": \"2.0\",
        \"method\": \"service.create\",
        \"params\": {
                \"name\" : \"$NOMEITEM\",
                \"algorithm\" : \"1\",
                \"showsla\" : \"1\",
                \"goodsla\" : \"99.99\",
                \"sortorder\" : \"1\",
                \"parentid\": \"$ITS_PID_CHILD\",
		\"triggerid\": \"$ITEM_TRIGID\"
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1}"  #| awk -v RS=',"' -F: '/^name/ {print $2}'
}
#mk_child_its_trigger;

# Inicio do Laço Populate
for HOSTGROUP in `get_hostgroups;`
do
	echo 1
	mk_father_itservices;
	for HOSTN in `get_hosts_hostgroups;`
	do
		echo 2
		mk_child_itservices $HOSTGROUP $HOSTN	
		for NOMEITEM in `get_items_hosts;`
		do
			echo 3
			mk_child_its_trigger $HOSTGROUP $HOSTN $NOMEITEM
		done
	done
done
 
	
