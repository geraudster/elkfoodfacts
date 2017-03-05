#!/usr/bin/env bash

rm -v ~/data/sincedb
curl -X DELETE http://localhost:9200/openfoodfact

/usr/share/logstash/bin/logstash --log.level=info --path.data ~/logstash-tmp --path.settings ~/conf -f ingest.conf 
