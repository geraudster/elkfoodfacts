#!/usr/bin/env bash

set -euf -o pipefail

echo Init random passwords
bin/elasticsearch-setup-passwords auto --batch --url https://elasticsearch:9200 | grep PASSWORD  | sed -E 's/PASSWORD ([^ ]+) = (.*)/\U\1\E_PASSWORD=\2/' > /tmp/.all_creds.env

echo Prepare env file for kibana
grep KIBANA_SYSTEM_PASSWORD /tmp/.all_creds.env | sed -E 's/KIBANA_SYSTEM_PASSWORD=/ELASTICSEARCH_PASSWORD=/' > /tmp/.kibana_creds.env

echo Add logstash_internal
source /tmp/.all_creds.env
LOGSTASH_INTERNAL_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-20};echo;)

curl -k -XPOST "https://elasticsearch:9200/_security/role/logstash_writer" \
     -u elastic:${ELASTIC_PASSWORD} \
     -H 'Content-Type: application/json' \
     -d'{  "cluster": ["manage_index_templates", "monitor", "manage_ilm"],   "indices": [    {      "names": [ "logstash-*", "openfoodfacts*" ],       "privileges": ["write","create","delete","create_index","manage","manage_ilm"]      }  ]}'

curl -k -XPOST "https://elasticsearch:9200/_security/user/logstash_internal" \
     -u elastic:${ELASTIC_PASSWORD} \
     -H 'Content-Type: application/json' \
     -d"{  \"password\" : \"${LOGSTASH_INTERNAL_PASSWORD}\",  \"roles\" : [ \"logstash_writer\" ]}"

echo "LOGSTASH_INTERNAL_PASSWORD=$LOGSTASH_INTERNAL_PASSWORD" >> /tmp/.all_creds.env

echo Generated passwords
cat /tmp/.all_creds.env
