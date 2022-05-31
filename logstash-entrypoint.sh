#!/bin/bash -x

source config/api-key/logstash-foodfacts.env
export LOGSTASH_FOODFACTS_API_KEY
exec /usr/local/bin/docker-entrypoint "$@"
