#!/bin/bash

sed -i -e "s/kdc.docker.local/$KDC_PORT_88_UDP_ADDR/g" /etc/krb5.conf

sed -e "s/sql\$/krbsql.docker.local/g" /etc/hosts >/tmp/hosts
cp /tmp/hosts /etc/hosts

kinit $KRB_USER

cargs="--negotiate -u :"

for carg in $REST_ARGS; do
  if [[ "$carg" =~ ^/ ]]; then
    carg=http://krbsql.docker.local:8091${carg}
  fi
  cargs="$cargs $carg"
done

curl $cargs | jq .
