#!/bin/bash

cargs=

for carg in $REST_ARGS; do
  if [[ "$carg" =~ ^/ ]]; then
    carg=http://${SQL_PORT_8091_TCP_ADDR}:8091${carg}
  fi
  cargs="$cargs $carg"
done

curl $cargs | jq .
