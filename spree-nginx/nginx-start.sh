#!/bin/bash

sed -i -e "s/SPREE_SERVER/$SPREE_PORT_8080_TCP_ADDR:$SPREE_PORT_8080_TCP_PORT/g" /etc/nginx/sites-available/default

for n in {2..4}; do
  sname=SPREE_${n}_NAME
  if [ -n "${!sname}" ]; then
    sserv=SPREE_${n}_SERVER
    saddr=SPREE_${n}_PORT_8080_TCP_ADDR
    sport=SPREE_${n}_PORT_8080_TCP_PORT
    sed -i -e "s/# server ${sserv}/server ${!saddr}:${!sport}/g" /etc/nginx/sites-available/default
  fi
done

/usr/sbin/nginx
