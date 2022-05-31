#!/usr/bin/env bash

if [ x${ELASTIC_PASSWORD} == x ]; then
    echo "Set the ELASTIC_PASSWORD environment variable in the .env file";
    exit 1;
elif [ x${KIBANA_PASSWORD} == x ]; then
    echo "Set the KIBANA_PASSWORD environment variable in the .env file";
    exit 1;
fi;
if [ ! -f config/certs/ca.zip ]; then
    echo "Creating CA";
    bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip;
    unzip config/certs/ca.zip -d config/certs;
fi;
if [ ! -f config/certs/certs.zip ]; then
    echo "Creating certs";
    echo -ne \
         "instances:\n"\
         "  - name: es01\n"\
         "    dns:\n"\
         "      - es01\n"\
         "      - localhost\n"\
         "    ip:\n"\
         "      - 127.0.0.1\n"\
         > config/certs/instances.yml;
    bin/elasticsearch-certutil cert --silent --pem -out config/certs/certs.zip --in config/certs/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key;
    unzip config/certs/certs.zip -d config/certs;
fi;

echo "Setting file permissions"
chown -R root:root config/certs;
find . -type d -exec chmod 755 \{\} \;;
find . -type f -exec chmod 640 \{\} \;;
chmod 644 config/certs/ca/ca.crt;

echo "Waiting for Elasticsearch availability";
until curl -s --cacert config/certs/ca/ca.crt https://es01:9200 | grep -q "missing authentication credentials"; do sleep 30; done;

echo "Setting kibana_system password";
until curl -s -X POST --cacert config/certs/ca/ca.crt -u elastic:${ELASTIC_PASSWORD} -H "Content-Type: application/json" https://es01:9200/_security/user/kibana_system/_password -d "{\"password\":\"${KIBANA_PASSWORD}\"}" | grep -q "^{}"; do sleep 10; done;

echo "Creating API key for logstash";
curl -s -X POST --cacert config/certs/ca/ca.crt -u elastic:${ELASTIC_PASSWORD} -H "Content-Type: application/json" https://es01:9200/_security/api_key?filter_path=id,api_key \
     -d @- <<EOF | sed -E 's/\{"id":"([^,"]*)","api_key":"([^,"]*)"\}/LOGSTASH_FOODFACTS_API_KEY=\1:\2/' | tee /tmp/api-key/logstash-foodfacts.env
{
  "name": "logstash-foodfacts-api-key",
  "role_descriptors": { 
    "logstash-foodfacts-role": {
      "cluster": ["manage_index_templates", "monitor"],
      "index": [
        {
          "names": ["openfoodfacts*"],
          "privileges": ["all"]
        }
      ]
    }
  },
  "metadata": {
    "application": "logstash-foodfacts-application"
  }
}
EOF

echo
echo "All done!";
